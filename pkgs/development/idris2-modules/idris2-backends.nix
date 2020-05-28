{ lib, stdenv, symlinkJoin, makeWrapper
, idris2, chez, racket, gambit
}:

let
  idris2-with-backend = {
      backendName, backends, extraDeps, priority, defaultBackend ? backendName
    }:
    stdenv.mkDerivation rec {
      inherit (idris2) version;

      name = "idris2-with-${backendName}-backend";
      nativeBuildInputs = [ makeWrapper ];
      buildInputs = [ idris2 ] ++ extraDeps;

      buildCommand =
        let envSets = lib.strings.concatMapStrings
                        ({ envName, bin}: " --set ${envName} ${bin}") backends;
        in ''
          makeWrapper "${idris2}/bin/.idris2-wrapped" \
            "$out/bin/idris2-with-${backendName}-backend" \
            --set IDRIS2_CG ${defaultBackend} ${envSets}

          ln -s $out/bin/idris2-with-${backendName}-backend $out/bin/idris2
        '';

      meta = idris2.meta // { priority = priority; };
    };
in {
  # idris2 uses scheme backend by default
  idris2-with-scheme-backend = idris2;

  idris2-with-racket-backend = idris2-with-backend {
    backendName = "racket";
    backends = [ { envName = "RACKET"; bin = "${racket}/bin/racket"; } ];
    extraDeps = [ racket ];
    priority = (idris2.meta.priority or 5) + 1;
  };

  idris2-with-gambit-backend = idris2-with-backend {
    backendName = "gambit";
    backends = [ { envName = "GAMBIT"; bin = "${gambit}/bin/gsc"; } ];
    extraDeps = [ gambit ];
    priority = (idris2.meta.priority or 5) + 2;
  };

  idris2-with-every-backend = idris2-with-backend {
    backendName = "every";
    backends = [
      { envName = "RACKET"; bin = "${racket}/bin/racket"; }
      { envName = "GAMBIT"; bin = "${gambit}/bin/gsc"; }
    ];
    extraDeps = [ racket gambit ];
    defaultBackend = "scheme";
    priority = (idris2.meta.priority or 5) - 1;
  };
}
