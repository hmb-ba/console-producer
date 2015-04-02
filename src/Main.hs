module Main (
  main
) where

import Types
import Network.Types
import Network.Writer

import Network.Socket
import System.IO
import Control.Monad
import Data.IP

import Common.Writer
import Common.Types
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString as BS 
import Data.Binary.Put
import qualified Data.ByteString.Char8 as C

packRequest :: InputMessage -> RequestMessage
packRequest iM = 
  let payload = Payload {
      keylen = 0
    , payloadLen = fromIntegral $ BS.length $ inputData iM
    , payloadData = inputData iM
  }
  in
  let message = Message { 
      crc = 0
    , magic = 0
    , attr= 0
    , payload = payload
  }
  in
  let messageSet = MessageSet {
      offset = 0
    , len = fromIntegral $ BL.length $ buildMessage message
    , message = message
  }
  in
  let partition = Partition {
      partitionNumber = inputPartitionNumber iM
    , messageSetSize = fromIntegral $ BL.length $ buildMessageSet messageSet
    , messageSet = [messageSet]
  }
  in
  let topic = Topic {
      topicNameLen = fromIntegral $ BS.length $ inputTopicName iM
    , topicName = inputTopicName iM
    , numPartitions = fromIntegral $ length [partition]
    , partitions = [partition]
  }
  in
  let request = ProduceRequest {
      requiredAcks = 0
    , timeout = 1500
    , numTopics = fromIntegral $ length [topic]
    , topics = [topic]
  }
  in
  let requestMessage = RequestMessage {
      requestSize = fromIntegral $ BL.length $ buildProduceRequestMessage request
    , apiKey = 0
    , apiVersion = 0
    , correlationId = 0
    , clientIdLen = fromIntegral $ BS.length $ inputClientId iM
    , clientId = inputClientId iM
    , request = request
  }
  in
  requestMessage


main = do
  sock <- socket AF_INET Stream defaultProtocol 
  setSocketOption sock ReuseAddr 1
  let ip = toHostAddress (read "127.0.0.1" :: IPv4)
  connect sock (SockAddrInet 4343 ip)
  putStrLn "ClientId eingeben"
  clientId <- getLine
  putStrLn "TopicName eingeben"
  topicName <- getLine
  forever $ do 
    putStrLn "Nachricht eingeben"
    inputMessage <- getLine
    print "a"
    let req = packRequest $ InputMessage (C.pack clientId) (C.pack topicName) (fromIntegral 1) (C.pack inputMessage)
    writeRequest sock req
    print "b"
  --return()
--open connection
--get arguments
--transform to requestmessage
--send messages
