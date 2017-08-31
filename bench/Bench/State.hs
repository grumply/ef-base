module Bench.State where

import Trivial

import Ef
import Ef.State

import Data.Functor.Identity

import qualified Control.Monad.Trans.State as St

suite = scope "state" $ tests
  [ states
  ]

states =
  scope "state" $ do
    let o = Object (state (0 :: Int) *:* Empty)
    br0 <- nf "ef/get/put/runWith" (\o -> snd $ runIdentity $ runWith o efGetPut) o
    notep br0
    -- br1 <- nf "ef/get/put/runWith'" (\o -> snd $ runIdentity $ runWith' o efGetPut) o
    -- notep br1
    br2 <- nf "mtl/get/put" (runIdentity . St.evalStateT mtlGetPut) (0 :: Int)
    notep br2
    report br0 br2
  where
    efGetPut = do
      x :: Int <- get
      y :: Int <- get
      z :: Int <- get
      put $! x + y + z

    mtlGetPut = do
      x :: Int <- St.get
      y :: Int <- St.get
      z :: Int <- St.get
      St.put $! x + y + z



