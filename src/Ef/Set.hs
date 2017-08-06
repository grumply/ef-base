module Ef.Set (Set, set, become) where

import Ef

import Unsafe.Coerce

data Set k where
    Set :: (Object ts c -> k) -> Set k
    Become_ :: Object ts c -> k -> Set k

instance Functor Set where
  fmap f (Set ok) = Set (fmap f ok)
  fmap f (Become_ o k) = Become_ o (f k)

pattern Become o = Become_ o (Return ())

instance Delta Set Set where
  delta eval (Set ok) (Become_ o k) = eval (ok (unsafeCoerce o)) k

set :: (Monad c, ts <. '[Set]) => Set (Action ts c)
set = Set (const . pure)

become :: (Monad c, ms <: '[Set], Delta (Modules ts) (Messages ms)) => Object ts c -> Ef ms c ()
become o = Send (Become o)
