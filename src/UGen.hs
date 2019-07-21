{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NamedFieldPuns #-}

module UGen where

import Foreign.C.String
import Foreign.C.Types
import Control.Concurrent
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign.Storable
import System.Posix.DynamicLinker

data SharedObject = SharedObject DL
  deriving (Show)

loadSO :: FilePath -> IO SharedObject
loadSO path = do
  SharedObject <$> dlopen path [RTLD_NOW]

apiVersion :: SharedObject -> IO Int
apiVersion (SharedObject dl) = do
  funPtr :: FunPtr (IO CInt) <- dlsym dl "api_version"
  fromIntegral <$> api_version_dynamic funPtr

foreign import ccall "dynamic"
  api_version_dynamic :: FunPtr (IO CInt) -> IO CInt

unitClassNames :: SharedObject -> IO [String]
unitClassNames (SharedObject dl) = do
  funPtr :: FunPtr (Ptr InterfaceTable -> IO ()) <- dlsym dl "load"
  ptr <- malloc
  mvar <- newMVar []
  poke ptr $ InterfaceTable $ \ name ->
    modifyMVar mvar $ \ old -> do
      return (old ++ [name], True)
  load_dynamic funPtr ptr
  readMVar mvar

foreign import ccall "dynamic"
  load_dynamic :: FunPtr (Ptr InterfaceTable -> IO ())
    -> Ptr InterfaceTable -> IO ()

data InterfaceTable = InterfaceTable {
  defineUnit :: String -> IO Bool
}

instance Storable InterfaceTable where
  sizeOf _ = 320
  alignment _ = 64
  peek _ = undefined
  poke ptr (InterfaceTable {defineUnit}) = do
    let c_defineUnit inUnitClassName _ _ _ _ = do
          result <- defineUnit =<< peekCString inUnitClassName
          return $ CBool $ if result then 0 else 1
    poke (plusPtr ptr 48) =<< fDefineUnit_wrapper c_defineUnit
    let defineBufGen _ _ = do
          return $ CBool 0
    poke (plusPtr ptr 72) =<< fDefineBufGen_wrapper defineBufGen

-- bool (*fDefineUnit)(const char* inUnitClassName, size_t inAllocSize,
--       UnitCtorFunc inCtor, UnitDtorFunc inDtor,
--       uint32 inFlags);
foreign import ccall "wrapper"
  fDefineUnit_wrapper ::
    (CString -> CLong -> FunPtr () -> FunPtr () -> CUInt -> IO CBool)
      -> IO (FunPtr (CString -> CLong -> FunPtr () -> FunPtr () -> CUInt -> IO CBool))

-- bool (*fDefineBufGen)(const char* inName, BufGenFunc inFunc);
foreign import ccall "wrapper"
  fDefineBufGen_wrapper ::
    (CString -> FunPtr () -> IO CBool)
      -> IO (FunPtr (CString -> FunPtr () -> IO CBool))
