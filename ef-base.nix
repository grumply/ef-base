{ mkDerivation, base, comonad, ef, free, ghc-prim, mtl, random
, semigroups, stdenv, stm, transformers
}:
mkDerivation {
  pname = "ef-base";
  version = "3.0.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base comonad ef free ghc-prim mtl random semigroups stm
    transformers
  ];
  homepage = "github.com/grumply/ef";
  description = "Base ef library including common Ef abstractions";
  license = stdenv.lib.licenses.bsd3;
}
