{-# LANGUAGE CPP #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeOperators, DataKinds #-}
module Data.Queue
  ( Queue
  , newQueue
  , arrive
  , collect
  ) where

import Ef

import TLC

import Data.IORef
import Control.Concurrent.MVar

-- Single consumer multiple producer queue.
-- Hopefully correct for that case, specifically.

data Queue a = Queue
  { queueBarrier  :: {-# UNPACK #-}!(MVar ())
  , internalQueue :: {-# UNPACK #-}!(IORef [a])
  } deriving Eq

{-# INLINE newQueue #-}
newQueue :: MonadIO c => c (Queue a)
newQueue = liftIO $ Queue <$> newEmptyMVar <*> newIORef []

{-# INLINE arrive #-}
arrive :: MonadIO c => Queue a -> a -> c (Bool ::: "Receiver inactive")
arrive Queue {..} a = liftIO $ do
  q <- atomicModifyIORef' internalQueue $ \q -> (a:q,q)
  tryPutMVar queueBarrier ()

{-# INLINE collect #-}
collect :: MonadIO c => Queue a -> c [a]
collect Queue {..} = liftIO $ do
  takeMVar queueBarrier
  atomicModifyIORef' internalQueue $ \q -> ([],reverse q)

