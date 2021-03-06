{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedLists #-}

module Data.List where

import           Data.Maybe  (Maybe (Nothing))
import           Data.Maybe  (Maybe (Just))
import           Data.String (IsString (fromString))
import           Prelude     (Bool (..), Char, Eq, Int, Show (show), String,
                              fst, otherwise, snd, (*), (+), (++), (-), (==),
                              (||))
import GHC.Exts (Item, IsList (fromList, toList))

data List a
  = Nil
  | Cons a (List a)

l3 :: List Int
l3 = [2, 1, 0]

length :: List a -> Int
length []        = 0
length (Cons _ l) = 1 + length l

-- >>> Data.List.length Nil
-- 0

-- >>> Data.List.length l3
-- 3

isEmpty :: List a -> Bool
isEmpty [] = True
isEmpty _   = False

-- >>> isEmpty l3
-- False

-- >>> isEmpty Nil
-- True

concat :: List a -> List a -> List a
concat [] b        = b
concat (Cons h t) b = h <| concat t b

-- >>> Data.List.concat (1 <| 2 <| Nil) (3 <| 4 <| Nil)
-- [1, 2, 3, 4]

concatMap :: (a -> List b) -> List a -> List b
concatMap _ []        = []
concatMap f (Cons h t) = concat (f h) (concatMap f t)

-- >>> Data.List.concatMap (Data.List.replicate 5) (1 <| 2 <| Nil)
-- [1, 1, 1, 1, 1, 2, 2, 2, 2, 2]

instance IsString (List Char) where
  fromString :: String -> List Char
  fromString ""      = []
  fromString (h : t) = Cons h (fromString t)

joinString :: Show a => String -> List a -> String
joinString _ []          = ""
joinString _ [h] = show h
joinString d (Cons h t)   = show h ++ d ++ joinString d t

join :: Show a => List Char -> List a -> List Char
join _ []          = []
join _ [h] = fromString (show h)
join d (Cons h t)   = concat (concat (fromString (show h)) d) (join d t)

-- >>> join ", " (1 <| 2 <| Nil)
-- ['1', ',', ' ', '2']

instance Show a => Show (List a) where
  show :: List a -> String
  show l = "[" ++ joinString ", " l ++ "]"

-- >>> show l3
-- "[2, 1, 0]"

-- >>> show (Cons 1 Nil)
-- "[1]"

contains :: Eq a => a -> List a -> Bool
contains _ []        = False
contains a (Cons h t) = h == a || contains a t

-- >>> contains 1 (Cons 1 Nil)
-- True

-- >>> contains 2 Nil
-- False

(<|) :: a -> List a -> List a
(<|) = Cons
infixr 5 <|

-- >>> contains 1 (1 <| 2 <| Nil)
-- True

head :: List a -> Maybe a
head []        = Nothing
head (Cons h _) = Just h

-- >>> Data.List.head (1 <| 2 <| 3 <| Nil)
-- Just 1

group :: Eq a => List a -> List (List a)
group []        = []
group (Cons h t) = let (s, t') = span (\x -> x == h) t in (h <| s) <| group t'

-- >>> Data.List.group (1 <| 1 <| 2 <| 1 <| 3 <| 3 <| 2 <| Nil)
-- [[1, 1], [2], [1], [3, 3], [2]]

map :: (a -> b) -> List a -> List b
map _ []        = []
map f (Cons h t) = f h <| map f t

span :: (a -> Bool) -> List a -> (List a, List a)
span _ [] = ([], [])
span f l@(Cons h t) | f h = let (l', r) = span f t in (h <| l', r)
                    | otherwise = ([], l)
-- >>> Data.List.span (< 5) (1 <| 2 <| 7 <| 9 <| 4 <| 1 <| Nil)
-- ([1, 2],[7, 9, 4, 1])

sum :: List Int -> Int
sum []        = 0
sum (Cons h t) = h + sum t

-- >>> Data.List.sum (1 <| 2 <| 3 <| Nil)
-- 6

product :: List Int -> Int
product []        = 1
product (Cons h t) = h * (product t)

-- >>> Data.List.product (1 <| 2 <| 3 <| 4 <| Nil)
-- 24

tail :: List a -> Maybe (List a)
tail []        = Nothing
tail (Cons _ t) = Just t

-- >>> Data.List.tail (1 <| 2 <| 3 <| 4 <| Nil)
-- Just [2, 3, 4]

-- >>> Data.List.tail (1 <| Nil)
-- Nothing

last :: List a -> Maybe a
last []          = Nothing
last [h] = Just h
last (Cons _ t)   = last t

-- >>> Data.List.last (1 <| 2 <| 3 <| 4 <| Nil)
-- Just 4

-- >>> Data.List.last (1 <| Nil)
-- Just 1

init :: List a -> Maybe (List a)
init []          = Nothing
init (Cons _ []) = Just []
init (Cons h t)   = case init t of
  Just l  -> Just (Cons h l)
  Nothing -> Just [h]

-- >>> Data.List.init (1 <| 2 <| 3 <| Nil)
-- Just [1, 2]

-- >>> Data.List.init (1 <| Nil)
-- Just []

replicate :: Int -> a -> List a
replicate 0 _ = []
replicate n v = v <| (replicate (n - 1) v)

-- >>> Data.List.replicate 4 "a"
-- ["a", "a", "a", "a"]

reverse :: List a -> List a
reverse []        = []
reverse (Cons h t) = case init t of
  Nothing -> h <| []
  Just _  -> concat (reverse t) (h <| [])

-- >>> Data.List.reverse (1 <| 2 <| 3 <| 4 <| Nil)
-- [4, 3, 2, 1]

instance IsList (List a) where
  type Item (List a) = a

  fromList :: [Item (List a)] -> List a
  fromList [] = Nil
  fromList (h:t) = Cons h (fromList t)

  toList :: List a -> [Item (List a)]
  toList Nil = []
  toList (Cons h t) = h : toList t
