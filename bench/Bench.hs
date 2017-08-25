{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE FlexibleContexts #-}
module Main where

import Trivial
import Ef.Base

import qualified Bench.Pipes as Pipes
import qualified Bench.State as State

main = Trivial.runOnly "pipes" suite

suite = tests
  [ State.suite
  , Pipes.suite
  ]
