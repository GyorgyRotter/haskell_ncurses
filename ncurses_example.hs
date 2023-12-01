import UI.NCurses

data Position_Type = Position { x::Integer
                              , y::Integer
                              }
     deriving(Show) -- to easily print the record

initial_Position :: Position_Type
initial_Position = Position { x = 20
                            , y = 20
                            }

data ShowDebug_Type = ShowDebug | NoDebug
     deriving(Eq)

data LoopParameters_Type = LoopParameters { curpos::Position_Type
                                          , showdebug::ShowDebug_Type
                                          , timeoutcounter::Integer
                                          }

initial_LoopParameters :: LoopParameters_Type
initial_LoopParameters = LoopParameters { curpos = initial_Position
                                        , showdebug = NoDebug
                                        , timeoutcounter = 0
                                        }

incTimeoutCounter :: LoopParameters_Type -> LoopParameters_Type
incTimeoutCounter lp@(LoopParameters { timeoutcounter = c } ) = lp { timeoutcounter = c + 1 }


-- getEvent timeout paremater
--   If the timeout is Nothing, getEvent blocks until an event is received.
--   If the timeout is specified, getEvent blocks for up to that many milliseconds.
--      If no event is received before timing out, getEvent returns Nothing.
--   If the timeout is 0 or less, getEvent will not block at all.
timeout :: Maybe Integer
timeout = Just 1000    -- high CPU USAGE!!!!


main :: IO ()
main =
   runCurses $ do

   setEcho False
--   setCursorMode CursorInvisible
   w <- defaultWindow

   loop w Nothing initial_LoopParameters
     where
       loop w lastevent loopparam =
          do
          (screen_height, screen_width) <- screenSize
          updateWindow w $ do
            moveCursor 0 0
            drawString (concat $ replicate (fromIntegral (screen_width)) " ")
            moveCursor 0 0
            drawString (show $ curpos loopparam) -- it works because of the "deriving(Show)"
            drawString "   press v to toggle more info"
            moveCursor (y (curpos loopparam)) (x.curpos $ loopparam)   -- two ways to reffer to fields of a record (using accessor functions)
          render
          e <- getEvent w timeout  -- this line could block!
          if showdebug loopparam == ShowDebug then
            updateWindow w $ do
              (cy,cx) <- cursorPosition
              moveCursor 1 0
              drawString (concat $ replicate (fromIntegral (screen_width)) " ")
              moveCursor 1 0
              drawString ("screen width: " ++ (show screen_width) ++ " screen height: " ++ (show screen_height) ++
                          " cursorPosition: " ++ "(" ++ (show cy) ++ ", " ++ (show cx) ++ ")" ++
                          " timeoutcounter: " ++ (show (timeoutcounter loopparam)) ++
                          " actevent: " ++ (show e) ++ " ")

          else
            updateWindow w $ do drawString ("")  -- here we need to do the nothing :)

          case e of
             Nothing -> do
                  loop w e (incTimeoutCounter loopparam)
                  return ()
             Just (EventCharacter '\ESC') -> do
                                             return ()
             Just (EventCharacter 'q') -> do
                                          return ()
             Just (EventCharacter 'w') -> do
                                          updateWindow w $ do
                                                           moveCursor 2 0
                                                           drawString "w pressed  " -- sometimes there are tricks like this... try to avoid them
                                          loop w e (loopparam {curpos = Position { x = (x.curpos $ loopparam), y = (y.curpos $ loopparam) - 1 }})
                                          return ()
             Just (EventCharacter 'd') -> do
                                          updateWindow w $ do
                                                           moveCursor 2 0
                                                           drawString "d pressed  "
                                          loop w e (loopparam {curpos = Position { x = (x.curpos $ loopparam) + 1, y = (y.curpos $ loopparam) }})
                                          return ()
             Just (EventCharacter 'a') -> do
                                          updateWindow w $ do
                                                           moveCursor 2 0
                                                           drawString "a pressed  "
                                          loop w e (loopparam {curpos = Position { x = (x.curpos $ loopparam) - 1, y = (y.curpos $ loopparam) }})
                                          return ()
             Just (EventCharacter 's') -> do
                                          updateWindow w $ do
                                                           moveCursor 2 0
                                                           drawString "s pressed  "
                                          loop w e (loopparam {curpos = Position { x = (x.curpos $ loopparam), y = (y.curpos $ loopparam) + 1}})
                                          return ()
             Just (EventCharacter 'v') -> do  -- verbose
                                          updateWindow w $ do
                                                           moveCursor 2 0
                                                           drawString "v pressed  "
                                                           moveCursor 1 0
                                                           clearLine
                                          loop w e (loopparam {showdebug = if (showdebug loopparam) == ShowDebug then NoDebug else ShowDebug})
                                          return ()
             _ -> do
                  updateWindow w $ do
                    moveCursor 2 0
                    drawString "other event"
                  loop w e loopparam
                  return ()
