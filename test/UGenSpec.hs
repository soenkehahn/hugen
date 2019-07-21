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
      unitClassNames so `shouldReturn`
        ["DegreeToKey", "Select", "TWindex", "Index", "IndexL", "FoldIndex",
         "WrapIndex", "IndexInBetween", "DetectIndex", "Shaper", "FSinOsc",
         "PSinGrain", "SinOsc", "SinOscFB", "VOsc", "VOsc3", "Osc", "OscN",
         "COsc", "Formant", "Blip", "Saw", "Pulse", "Klang", "Klank"]
