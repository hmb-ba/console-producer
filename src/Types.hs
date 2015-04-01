module Types (
  InputMessage
) where

import Network.Types

type InputPayload = String

data InputMessage = InputMessage
  { topicName       :: !TopicName
  , partitionNumber :: !PartitionNumber
  , message         :: !InputPayload
  }
