-- | module for all unit tests
module Test.Necklace.Unit
    -- exporting only the testSuite to get dead code warnings if anything else isn't used
    (tests) 
    where

import Prelude

import Data.Necklace (focus, insertRight, next, prev, size)
import Data.Necklace as Necklace
import Data.NonEmpty ((:|))
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert


tests :: TestSuite
tests = suite "Necklace unit tests" do

    test "singleton" do
        let n = Necklace.singleton 0
        Assert.equal 0 (focus n)
        Assert.equal 0 (focus $ next n)
        Assert.equal 0 (focus $ prev n)
        Assert.equal 1 (size n)
        Assert.equal (0 :| []) (Necklace.toUnfoldable1 n)
    
    test "insertRight on singleton" do
        let n0 = Necklace.singleton 0
        let n1 = insertRight 1 n0
        Assert.equal 0 (focus n1)
        let n2 = next n1
        Assert.equal 1 (focus n2)
        let n3 = next n2
        Assert.equal 0 (focus n3)
        Assert.equal 2 (size n3)

    test "insertRight in the middle" do
        let xs = (0 :| [1, 3])
        let n0 = Necklace.fromNonEmpty xs
        Assert.equal 0 (focus n0)
        let n1 = next n0
        Assert.equal 1 (focus n1)
        Assert.equal 3 (size n1)
        let n2 = insertRight 2 n1
        Assert.equal 1 (focus n2)
        let n3 = next n2
        Assert.equal 2 (focus n3)
        let n4 = next n3
        Assert.equal 3 (focus n4)
        let n5 = next n4
        Assert.equal 0 (focus n5)
        Assert.equal 4 (size n5)

    test "fromNonEmpty" do
        let xs = (0 :| [1, 2])
        let n0 = Necklace.fromNonEmpty xs
        Assert.equal 0 (focus n0)
        let n1 = next n0
        Assert.equal 1 (focus n1)
        let n2 = next n1
        Assert.equal 2 (focus n2)
        let n3 = next n2
        Assert.equal 0 (focus n3)
        Assert.equal 3 (size n3)

    test "toUnfoldable1 on sigleton" do
        let necklace = Necklace.singleton 0
        let xs' = Necklace.toUnfoldable1 necklace
        let xs = [0]
        Assert.assert
            (show xs <> " != " <> show xs')
            (xs == xs')

    test "toUnfoldable1 on manually constructed necklace" do
        let n0 = Necklace.singleton 0
        let n1 = next $ insertRight 1 n0
        let n2 = next $ insertRight 2 n1
        let n3 = next $ next $ insertRight 3 n2
        let xs' = Necklace.toUnfoldable1 n3
        let xs = [0, 1, 2, 3]
        Assert.assert
            (show xs <> " != " <> show xs')
            (xs == xs')

    test "to and from NonEmptyArray" do
        let xs = (0 :| [1, 2, 3, 4])
        let necklace = Necklace.fromNonEmpty xs
        let xs' = Necklace.toUnfoldable1 necklace
        Assert.assert
            (show xs <> " != " <> show xs')
            (xs == xs')
