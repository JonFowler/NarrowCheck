module Reach.Parser.PExpr where

import Reach.Lens

type OpId = String
type ConId = String
type VarId = String
type TypeId = String

data PExpr
  -- The following constructors are the "core" constructors, they are used for
  -- parsing and then PExpr are converted to only use these types
  = PApp PExpr PExpr
--  | PCase PExpr [PAlt PExpr] (Maybe PExpr)
  | PCon ConId [PExpr]
  | PVar VarId
  | PLam VarId PExpr
  | PLet VarId PExpr PExpr

  -- The following are used in parsing but then desugared to the above constructors
  | PParens PExpr
  | POp PExpr OpId PExpr 
  | POpVar OpId
  | POpL PExpr OpId
  | POpR OpId PExpr
  deriving (Show)
     
data PAlt a = PAlt Pattern a deriving (Show, Functor)

data Pattern = PatVar VarId
             | PatCon ConId [Pattern] deriving (Show)

getPatVar :: Pattern -> VarId
getPatVar (PatVar x) = x

getPatCon :: Pattern -> ConId
getPatCon (PatCon c ps) = c


data PDef = PDef {_defArgs :: [Pattern], _defBody :: PExpr} deriving (Show)
--data PDef = PDef {_defName :: VarId, _defArgs :: [Pattern], _defBody :: PExpr} deriving (Show)
makeLenses ''PDef

data PType = PType :-> PType
          | Type TypeId deriving (Show)

type PData = (TypeId, [(ConId, [PType])])

  --PData {_dataName :: TypeId, _dataCon :: [(ConId, [PType])]} deriving (Show)
--makeLenses ''PData



--data Expr = Case Expr [Alt]
--          | App Expr Expr
--          | Parens Expr
--          | ConE ConId [Expr]
--          | ConHole
--          | Op Expr OpId Expr
--          | Var VarId deriving (Show)

