module StateMachine.Door where

import           Universum
import           Control.Concurrent.Model

data Open   = Open
data Close  = Close
data Closed = Closed

exampleDoor :: Loger -> IO ()
exampleDoor loger = readDoorComands =<< makeDoor loger

makeDoor :: Loger -> IO StateMachine
makeDoor loger = runStateMachine loger Closed $ do
    ifE Close $ Open   >-> Closed
    ifE Open  $ Closed >-> Open

    mathS     Closed $ \Close -> putTextLn "Open door?"
    onEntry        Closed $ putTextLnIO "Open door?"
    onExit         Closed $ putTextLnIO "Door is now Open"

    mathS     Open $ \Open -> putTextLn "The door must be closed. OK?"
    onEntry        Open $ putTextLnIO "The door must be closed. OK?"
    onExit         Open $ putTextLnIO "Door is now Closed"

putTextLnIO :: Text -> IO ()
putTextLnIO = putTextLn

readDoorComands :: StateMachine -> IO ()
readDoorComands sm = do
    ln <- getLine
    case ln of
        "open"  -> notify sm Open  >> readDoorComands sm 
        "close" -> notify sm Close >> readDoorComands sm 
        "exit"  -> pure ()
        _       -> readDoorComands sm
