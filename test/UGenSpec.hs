module UGenSpec where

import Test.Hspec
import UGen

spec :: Spec
spec = do
  describe "loadSO" $ do
    it "returns the version" $ do
      so <- loadSO "test/resources/OscUGens.so"
      apiVersion so `shouldReturn` 3

    it "returns the class names" $ do
      so <- loadSO "test/resources/OscUGens.so"
      unitClassNames so `shouldReturn` ["huhu"]
