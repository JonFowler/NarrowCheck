
import Reach.Parser.Parser
import Reach.Parser.Conv
import Control.Monad.Except

import Reach.Eval.Basic
import Reach.Eval.Forward
import Reach.Eval

import System.Environment
import System.Console.GetOpt

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

go :: FilePath -> [Flag] -> IO ()
go fn flags = do
  a <- readProg fn
  case runExcept $ conv a of
    Left e -> print e
    Right fs -> do
      let (e, xs, s) = toProg fs dd 10
      let res =  map (\s -> map (getExp s) xs)  $ reachF e s 
      mapM_ (putStrLn . unwords . map printVal) res
  where
    (dd:_) = [d | DataBound d <- flags] ++ [100000000]

printWithErr :: (Show err) => Either err Exp -> String
printWithErr (Left err) = show err
printWithErr (Right e) =  printVal e


