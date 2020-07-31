module Data.List where

import           Prelude (Int, Show (show), String, (+), (++))
data List a
  = Nil
  | Cons a (List a)

l3 :: List Int
l3 = Cons 2 (Cons 1 (Cons 0 Nil))

length :: List a -> Int
length Nil        = 0
length (Cons _ l) = 1 + length l

instance Show a => Show (List a) where
  show :: List a -> String
  show l = "[" ++ join l ++ "]"

    where
      join :: Show a => List a -> String
      join Nil          = ""
      join (Cons h Nil) = show h
      join (Cons h t)   = show h ++ ", " ++ join t

-- >>> show l3
-- "[2, 1, 0]"

-- >>> show (Cons 1 Nil)
-- "[1]"

-- >>> Data.List.length Nil
-- 0

-- >>> Data.List.length l3
-- 3