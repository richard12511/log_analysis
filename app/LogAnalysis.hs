{-# OPTIONS_GHC -Wall #-}
module LogAnalysis where

import Log

getMessageType :: String -> String
getMessageType str = head (words str)

getErrorCode :: String -> Int
getErrorCode str = read (words str !! 1) :: Int

getTimeStamp :: String -> Int
getTimeStamp str 
    | getMessageType str == "E" = read (words str !! 2) :: Int
    | otherwise                 = read (words str !! 1) :: Int

getMessage :: String -> String
getMessage str
    | getMessageType str == "E" = concat (drop 3 (words str))
    | otherwise                 = concat (drop 2 (words str))

parseMessage :: String -> LogMessage
parseMessage str
    | getMessageType str == "I" = LogMessage Info (getTimeStamp str) (getMessage str)
    | getMessageType str == "W" = LogMessage Warning (getTimeStamp str) (getMessage str)
    | getMessageType str == "E" = 
        LogMessage (Error (getErrorCode str)) (getTimeStamp str) (getMessage str)
    | otherwise                 = Unknown str

parse :: String -> [LogMessage]
parse str = parseMessages (lines str)

parseMessages :: [String] -> [LogMessage]
parseMessages [] = []
parseMessages (x:xs) = (parseMessage x): parseMessages xs

isAfter :: LogMessage -> LogMessage -> Bool
isAfter (Unknown _) _ = True
isAfter _ (Unknown _) = True
isAfter (LogMessage _ ts1 _) (LogMessage _ ts2 _) = ts1 > ts2 

insert :: LogMessage -> MessageTree -> MessageTree
insert (Unknown _) msgTree = msgTree
insert lm Leaf = Node Leaf lm Leaf

insert lm (Node Leaf nodeMessage Leaf)
   | lm `isAfter` nodeMessage          = Node Leaf nodeMessage (Node Leaf lm Leaf)
   | otherwise                         = Node (Node Leaf lm Leaf) nodeMessage Leaf

insert lm (Node Leaf nodeMessage rightTree)
   | lm `isAfter` nodeMessage = Node Leaf nodeMessage (insert lm rightTree)
   | otherwise                = Node (Node Leaf lm Leaf) nodeMessage rightTree

insert lm (Node leftTree nodeMessage Leaf)
   | lm `isAfter` nodeMessage = Node leftTree nodeMessage (Node Leaf lm Leaf)
   | otherwise                = Node (insert lm leftTree) nodeMessage Leaf

insert lm (Node leftTree nodeMessage rightTree)
   | lm `isAfter` nodeMessage = Node leftTree nodeMessage (insert lm rightTree)
   | otherwise                = Node (insert lm leftTree) nodeMessage rightTree

build :: [LogMessage] -> MessageTree
build [] = Leaf
build [lm] = insert lm Leaf
build (x:xs) = insert x (build xs)

inOrder :: MessageTree -> [LogMessage]
inOrder Leaf = []
inOrder (Node Leaf lm Leaf) = [lm]
inOrder (Node leftTree lm rightTree) = (inOrder leftTree) ++ [lm] ++ (inOrder rightTree) 

isError :: MessageType -> Bool
isError (Error _) = True
isError _ = False

whatWentWrong :: [LogMessage] -> [String]
whatWentWrong [] = []
whatWentWrong logs = [message lm | lm <- (inOrder (build logs)), isError (messageType lm)] 