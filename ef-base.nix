{ mkDerivation, base, comonad, ef, free, ghc-prim, mtl, random
, semigroups, stdenv, stm, transformers, trivial, pipes, tlc
}:
mkDerivation {
  pname = "ef-base";
  version = "3.0.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base comonad ef free ghc-prim mtl random semigroups stm
    transformers tlc
  ];
  executableHaskellDepends = [
    base comonad ef free ghc-prim mtl random semigroups stm
    transformers trivial pipes tlc
  ];
  homepage = "github.com/grumply/ef";
  description = "Base ef library including common Ef abstractions";
  license = stdenv.lib.licenses.bsd3;
}
