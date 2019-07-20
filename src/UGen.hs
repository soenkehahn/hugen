{-# LANGUAGE ScopedTypeVariables #-}

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
  fromIntegral <$> cint_dynamic funPtr

foreign import ccall "dynamic"
  cint_dynamic :: FunPtr (IO CInt) -> IO CInt

unitClassNames :: SharedObject -> IO [String]
unitClassNames (SharedObject dl) = do
  ptr <- malloc
  poke ptr InterfaceTable
  funPtr :: FunPtr (Ptr InterfaceTable -> IO ()) <- dlsym dl "load"
  print "before"
  load_dynamic funPtr ptr
  print "after"
  undefined

foreign import ccall "dynamic"
  load_dynamic :: FunPtr (Ptr InterfaceTable -> IO ())
    -> Ptr InterfaceTable -> IO ()

data InterfaceTable = InterfaceTable

instance Storable InterfaceTable where
  sizeOf _ = 320
  alignment _ = 64
  peek _ = undefined
  poke ptr InterfaceTable = do
    print "poking"
    let foo _ _ _ _ _ = do
          putStrLn "hooooray"
          threadDelay 1000000
          return $ CBool 0
    print "poking"
    cfoo <- fDefineUnit_wrapper foo
    print "poking"
    poke (plusPtr ptr 48) cfoo
    print "poking"

foreign import ccall "wrapper"
  fDefineUnit_wrapper ::
    (CString -> CLong -> FunPtr () -> FunPtr () -> CUInt -> IO CBool)
      -> IO (FunPtr (CString -> CLong -> FunPtr () -> FunPtr () -> CUInt -> IO CBool))
-- bool (*fDefineUnit)(const char* inUnitClassName, size_t inAllocSize,
      -- UnitCtorFunc inCtor, UnitDtorFunc inDtor,
      -- uint32 inFlags);
