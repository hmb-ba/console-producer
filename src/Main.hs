module Main (
  main
) where

import Types

import Kafka.Client

import Network.Socket
import System.IO
import Control.Monad
import Data.IP
import Data.Word
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C

import qualified Network.Socket.ByteString.Lazy as SBL

main = do
  -----------------
  -- Init Socket with user input
  -----------------
  sock <- socket AF_INET Stream defaultProtocol 
  setSocketOption sock ReuseAddr 1
  putStrLn "Give IP "
  ipInput <- getLine
  let ip = toHostAddress (read ipInput :: IPv4)
  putStrLn "Give Port"
  portInput <- getLine
  connect sock (SockAddrInet 4343 ip) --TODO: Port Input 
  putStrLn "Give Client Id"
  clientId <- getLine
  putStrLn "Give Topic Name"
  topicName <- getLine
  putStrLn "Give Partition Number"
  partition <- getLine

  -------------------------
  -- Send / Receive Loop
  -------------------------
  forever $ do 
    putStrLn "Nachricht eingeben"
    inputMessage <- getLine
    sendRequest sock $ packPrRqMessage (clientId, topicName, (read partition ::Int), inputMessage)

    --------------------
    -- Receive Response
    --------------------
    input <- SBL.recv sock 4096
    let response = decodePrResponse input
    print response 
