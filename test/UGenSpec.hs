module UGenSpec where

import Test.Hspec
import UGen

spec :: Spec
spec = do
  describe "loadSO" $ do
    it "returns the version" $ do
      so <- loadSO "test/resources/OscUGens.so"
      apiVersion so `shouldReturn` 3
