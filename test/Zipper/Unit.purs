-- | module for all unit tests
module Test.Zipper.Unit
    -- exporting only the testSuite to get dead code warnings if anything else isn't used
    (tests) 
    where

import Prelude

import Data.List.Lazy (fromFoldable)
import Data.List.Lazy as List
import Data.Maybe (Maybe(..))
import Data.NonEmpty ((:|))
import Data.Zipper as Zipper
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert
import Test.Utils (PN(..), walkZipper)


tests :: TestSuite
tests = suite "Zipper unit tests" do

    test "constructors are all equivelant" do
        let zFromList = Zipper.fromList (fromFoldable [0, 1, 2, 3, 4])
        let list = (Zipper.toUnfoldable <$> zFromList) :: Maybe (Array Int)
        let zFromNonEmpty = Zipper.fromNonEmpty (0 :| List.fromFoldable [1, 2, 3, 4])
        let list1 = (Zipper.toUnfoldable <$> Just zFromNonEmpty) :: Maybe (Array Int)
        Assert.assert
            (show list <> " != " <> show list1)
            (zFromList == Just zFromNonEmpty)

    test "toUnfoldable" do
        let zipper = Zipper.fromNonEmpty (0 :| List.fromFoldable [1, 2, 3, 4])
        Assert.equal [0, 1, 2, 3, 4] (Zipper.toUnfoldable zipper)

    test "next and prev foward and back" do
        let zipper = Zipper.fromNonEmpty (0 :| List.fromFoldable [1, 2, 3, 4])
        let values = walkZipper [N, N, P, P, P] zipper
        Assert.equal [0, 1, 2, 1, 0] values
