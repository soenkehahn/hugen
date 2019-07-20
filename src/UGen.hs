{-# LANGUAGE ScopedTypeVariables #-}

module UGen where

import System.Posix.DynamicLinker
import Foreign.C.Types
import Foreign.Ptr

data SharedObject = SharedObject DL
  deriving (Show)

loadSO :: FilePath -> IO SharedObject
loadSO path = do
  SharedObject <$> dlopen path [RTLD_NOW]

apiVersion :: SharedObject -> IO Int
apiVersion (SharedObject dl) = do
  funPtr :: FunPtr (IO CInt) <- dlsym dl "api_version"
  fromIntegral <$> cint_dynamic funPtr

foreign import ccall "dynamic"
  cint_dynamic :: FunPtr (IO CInt) -> IO CInt
