module Data.ZipperM where

import Prelude

import Control.Monad.Maybe.Trans (MaybeT(..))
import Data.List.Lazy (List, nil, (:))
import Data.List.Lazy as List
import Data.Maybe (Maybe(..), maybe)
import Data.Traversable (sequence)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (class Unfoldable1, unfoldr1)
import Test.QuickCheck (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (Gen)
import Utils (tail')


data ZipperM m a = ZipperM (List (m a)) a (List (m a))

instance eqZipperM :: (Applicative m, Eq (m a), Eq a) => Eq (ZipperM m a) where
    eq z z' = toArray z == toArray z'

-- really only practical for non effectful zippers. TODO should it be included?
instance unfoldable1ZipperM :: Applicative m => Unfoldable1 (ZipperM m) where
    unfoldr1 :: forall a b. (b -> Tuple a (Maybe b)) -> b -> ZipperM m a
    unfoldr1 f z = case f z of
        Tuple x Nothing -> ZipperM nil x nil
        Tuple x (Just y) -> ZipperM nil x (pure <$> unfoldr1 f y)

instance functorZipperM :: Functor m => Functor (ZipperM m) where
    map f (ZipperM l x r) = ZipperM (map (map f) l) (f x) (map (map f) r)

-- ZipperM is not a comonad because extend cannot be implemented for arbitrary effects
-- implementing extend ends up having the type forall b a. (ZipperM a -> b) -> ZipperM a -> m (ZipperM b)

instance arbitraryZipperM :: (Arbitrary (m a), Arbitrary a) => Arbitrary (ZipperM m a) where
    arbitrary = do
        x <- arbitrary
        xs <- arbitrary :: Gen (Array (m a))
        pure $ fromList1 x (List.fromFoldable xs)

fromList1 :: forall m a. a -> List (m a) -> ZipperM m a
fromList1 = ZipperM nil

fromList :: forall m a. Applicative m => List (m a) -> m (Maybe (ZipperM m a))
fromList xs = case List.uncons xs of
    Nothing -> pure Nothing
    Just { head, tail } -> (\x -> Just $ fromList1 x tail) <$> head

singleton :: forall m a. a -> ZipperM m a
singleton x = ZipperM nil x nil

next :: forall m a. Applicative m => ZipperM m a -> m (Maybe (ZipperM m a))
next (ZipperM left z right) =
    map (\z' -> ZipperM (List.cons (pure z) left) z' (tail' right)) <$> (sequence $ List.head right)

prev :: forall m a. Applicative m => ZipperM m a -> m (Maybe (ZipperM m a))
prev (ZipperM left z right) =
    map (\z' -> ZipperM (tail' left) z' (List.cons (pure z) right)) <$> (sequence $ List.head left)

nextT :: forall m a. Applicative m => ZipperM m a -> MaybeT m (ZipperM m a)
nextT = MaybeT <<< next

prevT :: forall m a. Applicative m => ZipperM m a -> MaybeT m (ZipperM m a)
prevT = MaybeT <<< next

focus :: forall m a. ZipperM m a -> a
focus (ZipperM _ z _) = z

-- | moves the focus of the zipper to the first element
first :: forall m a. Monad m => ZipperM m a -> m (ZipperM m a)
first zipper = maybe (pure zipper) first =<< prev zipper

-- | moves the focus of the zipper to the last element
last :: forall m a. Monad m => ZipperM m a -> m (ZipperM m a)
last zipper = maybe (pure zipper) last =<< next zipper

-- | inserts a new value at to the left of the focus
insertLeft :: forall m a. m a -> ZipperM m a -> ZipperM m a
insertLeft x (ZipperM l z r) = ZipperM (List.cons x l) z r

-- | inserts a new value at to the right of the focus
insertRight :: forall m a. m a -> ZipperM m a -> ZipperM m a
insertRight x (ZipperM l z r) = ZipperM l z (List.cons x r)

toList :: forall m a. Applicative m => ZipperM m a -> List (m a)
toList (ZipperM l z r) = List.reverse l <> (pure z : nil) <> r

toArray :: forall m a. Applicative m => ZipperM m a -> Array (m a)
toArray (ZipperM l z r) = List.toUnfoldable (List.reverse l) <> [pure z] <> List.toUnfoldable r
