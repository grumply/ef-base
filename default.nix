{ mkDerivation, base, comonad, ef, exceptions, free, ghc-prim, mtl
, pipes, random, semigroups, stdenv, stm, tlc, transformers
, trivial
}:
mkDerivation {
  pname = "ef-base";
  version = "3.0.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base comonad ef exceptions free ghc-prim mtl random semigroups stm
    tlc transformers
  ];
  executableHaskellDepends = [
    base comonad ef exceptions free ghc-prim mtl pipes random
    semigroups stm tlc transformers trivial
  ];
  homepage = "github.com/grumply/ef";
  license = stdenv.lib.licenses.bsd3;
}
