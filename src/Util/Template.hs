module Util.Template (Template,makeTemplate,applyTemplate) where

import Text.Pandoc.Definition
import Text.Pandoc.Generic
import Data.Maybe
import Util.Meta

type VarFunc = String -> Maybe MetaValue
newtype Template = Template (VarFunc -> [Inline])

makeTemplate :: Meta -> [Inline] -> Template
makeTemplate dtv = Template . flip scan . scan (`lookupMeta` dtv)
  where
  scan = bottomUp . go
  go vf (x@(Math DisplayMath var):xs) = replaceVar (vf var) [x] ++ xs
  go _ x = x
  replaceVar val def' = fromMaybe def' $ val >>= toInlines

applyTemplate :: [Inline] -> [Inline] -> Template -> [Inline]
applyTemplate i t (Template g) = g internalVars
  where
  internalVars "i" = Just $ MetaInlines i
  internalVars "t" = Just $ MetaInlines t
  internalVars _   = Nothing
