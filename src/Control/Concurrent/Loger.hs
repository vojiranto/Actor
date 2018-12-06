module Control.Concurrent.Loger where

import           Control.Concurrent.Prelude
import           Control.Concurrent.Model.Data.TextId

type Loger = Text -> IO ()

-- | Alias for putTextLn.
logToConsole :: Loger
logToConsole = putTextLn

-- | Alias for (\\_ -> pure ()).
logOff :: Loger
logOff _ = pure ()

addTagToLoger :: (Text -> t) -> Text -> TextId -> IO (Text -> t)
addTagToLoger logerAction tag textId =
    pure $ \txt -> logerAction $ tag <> " " <> describe textId <> " " <> txt
