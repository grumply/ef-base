{-# LANGUAGE DataKinds, TypeOperators, RankNTypes #-}
{-# LANGUAGE FlexibleContexts, UndecidableInstances #-}
{-# LANGUAGE ViewPatterns #-}
module Ef.Async where

import Data.Promise

import Ef
import Ef.Event

-- import Data.Tree

import Control.Exception
import Control.Monad.Catch
import Control.Monad.Fail
import Control.Monad.Trans

newtype Async i ms c a = Async { runAsync :: ms <: '[Evented] => Ef ms c (Process i a) }

instance MonadIO c => Functor (Async i ms c) where
  fmap f efpr = Async $ do
    pra <- runAsync efpr
    prb <- process
    _   <- attach pra Callback
            { success = void . complete prb . f
            , updates = void . notify prb
            , failure = void . abort prb
            }
    return prb

instance (MonadIO c, Functor (Messages ms)) => Applicative (Async i ms c) where
  pure a = Async $ do
    p <- process
    void $ complete p a
    return p

  fab <*> fa = Async $ do
    pb  <- process
    pab <- runAsync fab
    _   <- attach pab Callback
            { success = \ab -> do
                pa <- runAsync fa
                void $ attach pa Callback
                  { success = void . complete pb . ab
                  , updates = void . notify pb
                  , failure = void . abort pb
                  }
            , updates = void . notify pb
            , failure = void . abort pb
            }
    return pb

instance (MonadIO c, Functor (Messages ms)) => MonadIO (Async i ms c) where
  liftIO ioa = Async $ do
    pr <- process
    a  <- liftIO ioa
    void $ complete pr a
    return pr

instance (MonadIO c, Functor (Messages ms)) => Monad (Async i ms c) where
  return = pure
  ma >>= amb = Async $ do
    pr <- process
    pa <- runAsync ma
    _  <- attach pa Callback
            { success = \a -> do
                pb <- runAsync (amb a)
                void $ attach pb Callback
                  { success = void . complete pr
                  , updates = void . notify pr
                  , failure = void . abort pr
                  }
            , updates = void . notify pr
            , failure = void . abort pr
            }
    return pr
  fail str = Async $ do
    p <- process
    abort p (AsyncFail str)
    return p

data AsyncFail = AsyncFail String
  deriving Show
instance Exception AsyncFail

instance (MonadIO c, Functor (Messages ms)) => MonadFail (Async i ms c) where
  fail str = Async $ do
    p <- process
    abort p (AsyncFail str)
    return p

data AsyncFails = AsyncFails [SomeException]
  deriving Show
instance Exception AsyncFails

-- asyncFailsTree :: SomeException -> Maybe (Forest (Either SomeException AsyncFail))
-- asyncFailsTree (fromException -> Just (AsyncFails fs)) = Just $ unfoldForest go fs
--   where
--     go :: SomeException -> (Either SomeException AsyncFail,[SomeException])
--     go se =
--       case fromException se of
--         Nothing ->
--           case fromException se of
--             Nothing -> (Left se,[])
--             Just (AsyncFails afs) -> (Left $ toException $ AsyncFails [],afs)
--         Just af -> (Right af,[])
-- asyncFailsTree _ = Nothing

-- prettyAsyncFails :: Forest (Either SomeException AsyncFail) -> String
-- prettyAsyncFails = drawForest . fmap (fmap show)

instance (MonadIO c, Functor (Messages ms)) => Alternative (Async i ms c) where
  empty = Async $ do
    p <- process
    abort p (AsyncFail "empty")
    return p
  fl <|> fr = Async $ do
    unified <- process
    pl      <- runAsync fl
    pr      <- runAsync fr
    attach pl Callback
      { success = void . complete unified
      , updates = void . notify unified
      , failure = \fl -> do
          void $ attach pr Callback
            { success = \_ -> return ()
            , updates = \_ -> return ()
            , failure = \fr -> void $ abort unified $ AsyncFails [fl,fr]
            }
      }
    attach pr Callback
      { success = void . complete unified
      , updates = void . notify unified
      , failure = \fr -> do
          void $ attach pl Callback
            { success = \_ -> return ()
            , updates = \_ -> return ()
            , failure = \fl -> void $ abort unified $ AsyncFails [fl,fr]
            }
      }
    return unified

instance (MonadIO c, Functor (Messages ms)) => MonadPlus (Async i ms c) where
  mzero = empty
  mplus = (<|>)

instance (MonadIO c, Functor (Messages ms)) => MonadThrow (Async i ms c) where
  throwM e = Async $ do
    p <- process
    abort p e
    return p

instance (MonadIO c, Functor (Messages ms)) => MonadCatch (Async i ms c) where
  catch ma h = Async $ do
    p <- runAsync ma
    attach p Callback
      { success = \_ -> return ()
      , updates = \_ -> return ()
      , failure = \se ->
          case fromException se of
            Nothing -> return ()
            Just e  -> void $ runAsync $ h e
      }
    return p

liftAsync :: (MonadIO c, Functor (Messages ms)) => Ef ms c a -> Async i ms c a
liftAsync ef = Async $ do
  a <- ef
  p <- process
  complete p a
  return p

liftAsyncIO :: (MonadIO c, Functor (Messages ms)) => IO a -> Async i ms c a
liftAsyncIO = liftAsync . liftIO