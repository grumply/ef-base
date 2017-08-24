{-# language CPP #-}
module Data.Queue
  ( Queue
  , newQueue
  , arrive
  , collect
  ) where

import Ef

import Control.Concurrent.STM
import Control.Concurrent.STM.TQueue
import Data.Monoid

data Queue a = Queue {-# UNPACK #-} !(TQueue a)
  deriving Eq

newQueue :: MonadIO c => c (Queue a)
newQueue = liftIO $ Queue <$> newTQueueIO

arrive :: MonadIO c => Queue a -> a -> c ()
arrive (Queue q) a = liftIO $ atomically $ writeTQueue q a

collect :: MonadIO c => Queue a -> c a
collect (Queue q) = liftIO $ atomically $ readTQueue q

