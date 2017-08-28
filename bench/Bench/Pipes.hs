module Bench.Pipes where

import Trivial

import qualified Ef.Pipes as Ef
import qualified Pipes as Pipes

import Data.Functor.Identity

suite = scope "pipes" $ tests
  [ simple 10
  ]

simple n = scope ("simple " ++ show n) $ do
  br1 <- nf "ef"    (runIdentity . ef   ) n
  br2 <- nf "pipes" (runIdentity . pipes) n
  report br1 br2


{-# INLINE ef #-}
{-# INLINE pipes #-}
ef, pipes :: Monad m => Int -> m ()
ef n = Ef.runEffect $ produce n Ef.>-> consume
  where
    {-# INLINE consume #-}
    consume = do -- forever Ef.await
      Ef.await
      consume

    produce 0 = return ()
    produce n = do
      Ef.yield n
      produce (n - 1)

pipes n = Pipes.runEffect $ produce n Pipes.>-> consume
  where
    {-# INLINE consume #-}
    consume = do -- forever Pipes.await
      Pipes.await
      consume

    produce 0 = return ()
    produce n = do
      Pipes.yield n
      produce (n - 1)
