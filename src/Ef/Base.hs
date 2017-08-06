module Ef.Base (module Ef.Base,module X) where

import Ef as X

import Ef.Event as X
import Ef.Except as X
import Ef.Fiber as X
import Ef.Fork as X
import Ef.Manage as X
import Ef.Reader as X
import Ef.State as X
import Ef.Writer as X

import Data.Promise as X
import Data.Queue as X

import System.Random.Shuffle as X

liftIO_ :: MonadIO m => IO a -> m ()
liftIO_ = void . liftIO

lift_ :: (Monad m, Functor (t m), MonadTrans t) => m a -> t m ()
lift_ = void . lift

super_ :: (Functor (Messages ms), Monad c) => c (Ef ms c a) -> Ef ms c ()
super_ = void . super
