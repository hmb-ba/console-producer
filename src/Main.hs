module Main (
  main
) where

import Types

import HMB.Client.Producer

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
  putStrLn "IP eingeben"
  ipInput <- getLine
  let ip = toHostAddress (read ipInput :: IPv4)
  putStrLn "Port eingeben"
  portInput <- getLine
  --let port = read portInput ::PortNumber  -- PortNumber does not derive from read
  connect sock (SockAddrInet 4343 ip)
  putStrLn "ClientId eingeben"
  clientId <- getLine
  putStrLn "TopicName eingeben"
  topicName <- getLine

  -------------------------
  -- Send / Receive Loop
  -------------------------
  forever $ do 
    putStrLn "Nachricht eingeben"
    inputMessage <- getLine
    let req = packRequest $ InputMessage (C.pack clientId) (C.pack topicName) (fromIntegral 0) (C.pack inputMessage)
    
    sendRequest sock req

    --------------------
    -- Receive Response
    --------------------
    input <- SBL.recv sock 4096
    let i = input 
    response <- readProduceResponse $ i
    print response 
