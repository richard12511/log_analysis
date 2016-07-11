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
insert logMessage (Node Leaf nodeMessage Leaf)
	| logMessage `isAfter` nodeMessage = Node Leaf nodeMessage (Node Leaf logMessage Leaf)
	| otherwise						   = Node (Node Leaf logMessage Leaf) nodeMessage Leaf
insert logMessage (Node Leaf nodeMessage rightTree)
	| logMessage `isAfter` nodeMessage = Node Leaf nodeMessage (insert logMessage rightTree)
	| otherwise 					   = Node (Node Leaf logMessage Leaf) nodeMessage rightTree
insert logMessage (Node leftTree nodeMessage Leaf)
	| logMessage `isAfter` nodeMessage = Node leftTree nodeMessage (Node Leaf logMessage Leaf)
	| otherwise 					   = Node (insert logMessage leftTree) nodeMessage Leaf
insert logMessage (Node leftTree nodeMessage rightTree)
	| logMessage `isAfter` nodeMessage = Node leftTree nodeMessage (insert logMessage rightTree)
	| otherwise						   = Node (insert logMessage leftTree) nodeMessage rightTree