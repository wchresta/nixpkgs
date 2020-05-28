{ pkgs }:

rec {
  idris2 = pkgs.callPackage ./idris2.nix { };

  idris2-backends = pkgs.callPackage ./idris2-backends.nix { };

  idris2-with-racket-backend = idris2-backends.idris2-with-racket-backend ;

  idris2-with-gambit-backend = idris2-backends.idris2-with-gambit-backend ;

  idris2-with-every-backend = idris2-backends.idris2-with-every-backend ;
}
