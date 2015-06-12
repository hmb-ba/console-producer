module Main (
  main
) where

import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C

import Control.Monad

import Data.IP
import Data.Word

import Kafka.Client

import Network.Socket

import System.IO

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
  client <- getLine

  let requestHeader = Head 0 0 (stringToClientId client)

  -------------------
  -- Get Metadata from known broker
  ------------------
  let mdReq = Metadata requestHeader [] -- request Metadata for all topics
  sendRequest sock mdReq
  mdInput <- SBL.recv sock 4096
  let mdRes = decodeMdResponse mdInput
  print "Brokers Metadata:"
  print  mdRes

  ---------------
  -- Start Producing
  --------------
  putStrLn "Give Topic Name"
  topicName <- getLine
  let t = stringToTopic topicName
  putStrLn "Give Partition Number"
  partition <- getLine
  let p = read partition :: Int

  -------------------------
  -- Send / Receive Loop
   -------------------------
  forever $ do 
    putStrLn "Nachricht eingeben"
    input <- getLine
    let prReq = Produce requestHeader [ ToTopic t [ ToPart p [(stringToData input)]]]
    sendRequest sock $ prReq

    --------------------
    -- Receive Response
    --------------------
    input <- SBL.recv sock 4096
    let response = decodePrResponse input
    print response 
