module Types (
  InputMessage(..)
) where

import HMB.Network
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL

data InputMessage = InputMessage
  { inputClientId        :: !ClientId
  , inputTopicName       :: !TopicName
  , inputPartitionNumber :: !PartitionNumber
  , inputData       :: !BS.ByteString
  }
