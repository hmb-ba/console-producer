module Main (
  main
) where

import Types
import HMB.Network
import HMB.Network.Writer.Request
import HMB.Common

import Network.Socket
import System.IO
import Control.Monad
import Data.IP
import Data.Binary.Put
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C

import Data.Digest.CRC32

packRequest :: InputMessage -> RequestMessage
packRequest iM = 
  let payload = Payload {
      keylen = 0
    , magic = 0
    , attr= 0
    , payloadLen = fromIntegral $ BS.length $ inputData iM 
    , payloadData = inputData iM
  }
  in
  let message = Message { 
      crc = crc32 $ buildPayload payload
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
      reqRequiredAcks = 0
    , reqTimeout = 1500
    , reqNumTopics = fromIntegral $ length [topic]
    , reqTopics = [topic]
  }
  in
  let requestMessage = RequestMessage {
      reqSize = fromIntegral $ (BL.length $ buildProduceRequestMessage request )
          + 2 -- reqApiKey
          + 2 -- reqApiVersion
          + 4 -- correlationId 
          + 2 -- clientIdLen
          + (fromIntegral $ BS.length $ inputClientId iM) --clientId
    , reqApiKey = 0
    , reqApiVersion = 0
    , reqCorrelationId = 0
    , reqClientIdLen = fromIntegral $ BS.length $ inputClientId iM
    , reqClientId = inputClientId iM
    , request = request
  }
  in
  requestMessage


main = do
  sock <- socket AF_INET Stream defaultProtocol 
  setSocketOption sock ReuseAddr 1
  putStrLn "IP eingeben"
  ipInput <- getLine
  let ip = toHostAddress (read ipInput :: IPv4)
  putStrLn "Port eingeben"
  portInput <- getLine
  let port =  PortNum $ read portInput -- todo
  connect sock (SockAddrInet 9092 ip)
  putStrLn "ClientId eingeben"
  clientId <- getLine
  putStrLn "TopicName eingeben"
  topicName <- getLine
  forever $ do 
    putStrLn "Nachricht eingeben"
    inputMessage <- getLine
    let req = packRequest $ InputMessage (C.pack clientId) (C.pack topicName) (fromIntegral 0) (C.pack inputMessage)
    print req
    writeRequest sock req
    sClose sock


