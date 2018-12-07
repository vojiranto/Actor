module Control.Concurrent.Actor.Interpreter where

import           Control.Concurrent.Prelude
import qualified Data.Map as M
import           Control.Concurrent.Actor.Language
import           Control.Concurrent.Actor.Message
import           Control.Concurrent.Model

interpretActorL :: Loger -> Actor -> IORef HandlerMap -> ActorF a -> IO a
interpretActorL loger _ m (Math messageType handler next) = do
    loger Trace $ "[add handler] " <> describe messageType
    next <$> modifyIORef m (M.insert messageType (toSafe loger messageType handler))

interpretActorL loger link _ (This next) = do
    loger Trace "[get this *] "
    pure $ next link

interpretActorL loger _ _ (LiftIO action next) = do
    loger Trace "[IO action]"
    next <$> action
    

makeHandlerMap :: Loger -> Actor -> ActorL a-> IO HandlerMap
makeHandlerMap loger link h = do
    m <- newIORef mempty
    void $ foldFree (interpretActorL loger link m) h
    readIORef m

toSafe :: Loger -> EventType -> (Event -> IO ()) -> Event -> IO ()
toSafe loger messageType action message = catchAny (action message) $ \ex ->
    loger Warn $ show ex <> " in action with message " <> describe messageType
