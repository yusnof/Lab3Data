{-# OPTIONS -Wall #-}

--------------------------------------------------------------------------------

module AATree (
  AATree,        -- type of AA search trees
  emptyTree,     -- AATree a
  get,           -- Ord a => a -> AATree a -> Maybe a
  insert,        -- Ord a => a -> AATree a -> AATree a
  inorder,       -- AATree a -> [a]
  size,          -- AATree a -> Int
  height,        -- AATree a -> Int
  checkTree      -- Ord a => AATree a -> Bool
 ) where

--------------------------------------------------------------------------------

-- AA search trees
data AATree a = Empty | Node { level :: Int,  left :: AATree a,  value :: a,  right :: AATree a }
  deriving (Eq, Show, Read)

emptyTree :: AATree a
emptyTree = Empty 

{- 
Returns an element from the tree.
O(log n)
-}
get :: Ord a => a -> AATree a -> Maybe a
get _ Empty = Nothing
get x (Node _ l c r) 
  | x == c = Just c 
  | x > c = get x r 
  | x < c = get x l
  | otherwise = Nothing 

   
{-
  We compare the levels of the children to the right of the input 
  Node and if we have the case when we created a three node then we split the tree 
  O(1)
-}
split :: AATree a -> AATree a
split (Node levelx lx cx (Node levely ly cy (Node levelz lz cz rz))) 
  | (levelx == levely) && (levely == levelz) = --Determine that the fourth node is created
  Node (levely+1) (Node levelx lx cx ly) cy (Node levelz lz cz rz)
split a = a

{- 
If the input tree is empty, return empty
If the input tree has a empty child we insert
If the input tree has a empty child and lvl equals lvla 
      x <- y    becomes   x -> y
     /\    \             /    /\
    A  B    C           A     B C 
Otherwise we return input
O(1) 
-}
skew :: AATree a -> AATree a
skew Empty = Empty
skew (Node lvl Empty v r) = Node lvl Empty v r
skew (Node lvl (Node lvla l v rr) y r) | lvl == lvla = Node lvla l v (Node lvl rr y r)
skew a = a

{-
The base case is inserting a element into an empty tree. 
In the other cases we compare the value with inserted element and based on the statment, inserting in the right or left Node after that
with the help of the helper function skew and split. 
In the case of equal value then we do nothing.
In every case we insert a value we call on split and skew
O(log n)
-}
insert :: Ord a => a -> AATree a -> AATree a
insert x Empty = Node 1 Empty x Empty --Base case
insert x y@(Node level left value right) 
 | x < value = helpf (Node level (insert x left) value right) --if inserted value is bigger then existing value, insert into left node.
 | x > value = helpf (Node level left value (insert x right)) --if inserted value is smaller then existing value, insert into right node.
 | otherwise = y --Case of same value as existing, return the inserted input to avoid duplicates 
  where 
    helpf tree = split (skew tree)


-- Returns a inorder list from a tree
-- O(n)  
inorder :: AATree a -> [a]
inorder Empty = []
inorder (Node _ Empty x Empty) = [x] 
inorder (Node _ l c r) = inorder l ++ [c] ++ inorder r

-- returns the size/amount of node in a tree 
-- O(n)
size :: AATree a -> Int
size Empty = 0
size (Node _ l _ r) = 1 + size l + size r 

-- returns the number of levels / height of tree
-- O(1)
height :: AATree a -> Int
height Empty = 0
height (Node _ left _ right) = 1 + max (height left) (height right) 
  
--------------------------------------------------------------------------------
-- Check that an AA tree is ordered and obeys the AA invariants
-- O(n) to be accurate O(3n)
checkTree :: Ord a => AATree a -> Bool
checkTree root =
  isSorted (inorder root) &&
  all checkLevels (nodes root)
  where
    nodes x
      | isEmpty x = []
      | otherwise = x:nodes (leftSub x) ++ nodes (rightSub x)

-- True if the given list is ordered
-- O(n)
isSorted :: Ord a => [a] -> Bool
isSorted [] = True
isSorted (x:y:xs) = x < y && isSorted xs  
isSorted _ = True  
  
{- Check if the invariant is true for a single AA node
-- You may want to write this as a conjunction e.g.
--   checkLevels node =
--     leftChildOK node &&
--     rightChildOK node &&
--     rightGrandchildOK node
-- where each conjunct checks one aspect of the invariant
O(n)
-}
checkLevels :: AATree a -> Bool
checkLevels Empty = True
checkLevels (Node level left _ right) = 
  level >=  getLvl left &&
  level >= getLvl right &&
  level > getLvl (rightSub right)
   where
    getLvl Empty = 0
    getLvl (Node lvl _ _ _) = lvl 

--O(1)
isEmpty :: AATree a -> Bool
isEmpty Empty = True
isEmpty _ = False 

-- returns a left tree subtree 
--O(1)
leftSub :: AATree a -> AATree a
leftSub Empty           = Empty
leftSub (Node _ l _ _ ) = l

-- returns a right tree subtree
--O(1) 
rightSub :: AATree a -> AATree a
rightSub Empty           = Empty 
rightSub (Node _ _ _ r ) = r 

--------------------------------------------------------------------------------

