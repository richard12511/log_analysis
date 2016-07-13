-- CIS 194 Homework 2

module Log where

import Control.Applicative

data MessageType = Info
                 | Warning
                 | Error Int
  deriving (Show, Eq)

type TimeStamp = Int

data LogMessage = LogMessage { messageType :: MessageType, 
                               timeStamp   :: TimeStamp, 
                               message     :: String }
                | Unknown String
  deriving (Show, Eq)

data MessageTree = Leaf
                 | Node { left :: MessageTree, logMessage :: LogMessage, right :: MessageTree }
  deriving (Show, Eq)

-- | @testParse p n f@ tests the log file parser @p@ by running it
--   on the first @n@ lines of file @f@.
testParse :: (String -> [LogMessage])
          -> Int
          -> FilePath
          -> IO [LogMessage]
testParse parse n file = take n . parse <$> readFile file

-- | @testWhatWentWrong p w f@ tests the log file parser @p@ and
--   warning message extractor @w@ by running them on the log file
--   @f@.
testWhatWentWrong :: (String -> [LogMessage])
                  -> ([LogMessage] -> [String])
                  -> FilePath
                  -> IO [String]
testWhatWentWrong parse whatWentWrong file
  = whatWentWrong . parse <$> readFile file

logMessage2 = LogMessage Info 25 "message 2"
msgTree2 = Node Leaf logMessage2 Leaf

logMessage1 = LogMessage Info 20 "message 1"
msgTree1 = Node Leaf logMessage1 msgTree2

logMessage3 = LogMessage Info 26 "message 3"

logMessage4 = LogMessage (Error 52) 30 "error 1"



