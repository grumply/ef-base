{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import Trivial
import Ef.Base

main = do
    void $ Object ((state (0 :: Int)) *:* state (0 :: Integer) *:* Empty) ! do
      i :: Int <- get
      i' :: Integer <- get
      put (i + 1)
      put (i' + 2)
      i :: Int <- get
      i' :: Integer <- get
      if (i,i') == (1,2) then return () else error "Uh-oh!"
