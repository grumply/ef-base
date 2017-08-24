{ compiler ? "ghc801" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = new: old: rec {

              trivial =
                new.callPackage ./deps/trivial/trivial.nix { };

              ef =
                new.callPackage ./deps/ef/ef.nix { };

              ef-base =
                new.callPackage ./ef-base.nix { };

            };
          };
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };

in
  { ef = pkgs.haskell.packages.${compiler}.ef;
    ef-base = pkgs.haskell.packages.${compiler}.ef-base;
    trivial = pkgs.haskell.packages.${compiler}.trivial;
  }

