
import qualified Reach.Parser.Module as P
import qualified Reach.Parser.Conv as C
import Reach.Eval.Cont
import Reach.Eval.Expr
import Reach.Eval.Env
import Reach.Lens
import Reach.Printer
      
import Control.Monad.Except

import System.Environment
import System.Console.GetOpt
import System.IO.Error

data Flag 
  = DataBound Int

options :: [OptDescr Flag]
options =
  [ Option ['d'] [] (ReqArg dbound "NUM")
      "data-depth bound"
  ]
  where dbound s 
          | n >= 0 = DataBound n
          | otherwise = error "DataDepth Bound must be positive"
          where n = read s

main :: IO ()
main = do
  args <- getArgs
  case getOpt Permute options args of
    (fs, [fn], []) -> go fn fs
    (_, _ , errs) -> error $ concat errs ++
                      usageInfo header options
  where header = "Usage: reach [OPTION...] FILE.rh"

toFileName :: [String] -> FilePath
toFileName [a] = a ++ ".hs"
toFileName (a : as) = a ++ "/" ++ toFileName as
  
go :: FilePath -> [Flag] -> IO ()
go fn flags = do
  rf <- readFile fn
  m <- P.parseModule rf
  let fns = map toFileName $ ["Prelude"] : m ^. P.moduleImports
  ms <- mapM (readFile >=> P.parseModule) fns
  m' <- P.mergeModules m ms
  P.checkModule m'
  let env = C.convModule m'
      fid = env ^. funcIds .at' "reach"
      Func allfunc _ = env ^. funcs . at' (env ^. funcIds .at' "test")
      fal = env ^. constrIds . at' "False"
  let rs = runF fid env
  printResults (take 10 . filter (\(Con cid _, _) -> cid == fal) $ rs)


printResults :: [(Atom, Env)] -> IO ()
printResults = mapM_ (\(e,env) -> putStrLn (showAtom env e ++ " -> " ++ printFVar env 0
                                           ++ "\n     " ++ printFVar env 1))

runF :: FId -> Env -> [(Atom, Env)]
runF fid env = runReach
                 (do
                    x <- newFVar
                    y <- newFVar
                    evalLazy (Fun fid)
                       [Apply . atom . FVar $ x, Apply . atom . FVar $ y]
                 )
                 env


--runF :: FId -> Env -> [(Expr, Env)]
--runF fid env = runReach (newFVar >>= (\x -> evalLazy (App (Fun fid) (FVar x)) Fin)) env
