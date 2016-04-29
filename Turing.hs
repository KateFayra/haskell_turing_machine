--     Copyright 2016 Nicholas Lochner
--     http://njlochner.com
--     https://github.com/njlochner
--
--     This file is part of Nicholas Lochner's Haskell Turing Machine simulator.
--
--     Nicholas Lochner's Haskell Turing Machine simulator is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
--
--     Nicholas Lochner's Haskell Turing Machine simulator is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License
--     along with Nicholas Lochner's Haskell Turing Machine simulator.  If not, see <http://www.gnu.org/licenses/>.

import qualified Data.HashMap.Strict as H

fixMe = error "Fix Me!"

type TMSymTable = (H.HashMap String TMInstruction)

data TMState = State TMSymTable
  deriving (Show, Eq)

data TMInstruction = Instruction String Direction String
  deriving (Show, Eq)

data Direction = TapeRight
               | TapeLeft
  deriving (Show, Eq)

type Machine = (H.HashMap String TMState)
type Tape = [String]
type Alphabet = [String]

--runMachine :: Machine -> Alphabet -> Tape -> String -> Tape
--runMachine machine alphabet tape startState = runInternal machine alphabet tape startState
--
--runInternal :: Machine -> Alphabet -> Tape -> String -> Tape
--runInternal = fixMe

runStep :: Machine -> Alphabet -> Tape -> String -> Int -> (Tape, String, Int)
runStep machine alphabet tape startState position = processState (H.lookup startState machine) tape position

processState (Just (State symTable)) tape position = handleAddingTape (processInstruction (H.lookup (tape!!position) symTable) tape position)

processInstruction (Just (Instruction writeSymbol dir nextState)) tape position
    | dir == TapeRight = (replaceAtIndex position writeSymbol tape, nextState, (position-1))
    | otherwise = (replaceAtIndex position writeSymbol tape, nextState, (position+1))

handleAddingTape (tape, nextState, position)
    | position < 0 = ("":tape, nextState, position+1)
    | position == (length tape) = (tape ++ [""], nextState, position-1)
    | otherwise = (tape, nextState, position)

runVerbose :: Machine -> Alphabet -> Tape -> String -> IO ()
runVerbose machine alphabet tape startState = loop 0 machine alphabet tape startState 0

loop :: Int -> Machine -> Alphabet -> Tape -> String -> Int -> IO ()
loop i machine alphabet tape startState position =
                           do  putStr ("Step " ++ show i ++ ". Tape: [" ++ showTape tape position "" 0 ++ "]" ++ "\n" ++ "Step " ++ show i ++ ". On state " ++ show startState ++ "\n"
                                        -- ++ ": [" ++ showState alphabet (H.lookup startState machine) ++ "]\n"
                                        ++ "Step " ++ show i ++ ". " ++ showInstruction machine alphabet tape startState position ++ "\n\n")
                               let (newTape, newState, newPosition) = runStep machine alphabet tape startState position in
                                   if newState == "HALT"
                                        then putStr ("Step " ++ show (i+1) ++ ". Tape: [" ++ showTape newTape newPosition "" 0 ++ "]" ++ "\n" ++ "Step " ++ show (i+1) ++ ". HALTING Program Complete." ++ "\n")
                                   else loop (i+1) machine alphabet newTape newState newPosition



showTape :: Tape -> Int -> String -> Int -> String
showTape [] position str i = str
showTape (a:tape) position str i
    | position == i = showTape tape position (str ++ ((getPrefix i) ++ "*" ++ show a)) (i+1)
    | otherwise = showTape tape position (str ++ ((getPrefix i) ++ show a)) (i+1)

getPrefix :: Int -> String
getPrefix i
    | i > 0 = ", "
    | otherwise = ""

showState :: Alphabet -> Maybe TMState -> String
showState alphabet (Just (State symTable)) = showSymTable alphabet symTable ""

showSymTable :: Alphabet -> TMSymTable -> String -> String
showSymTable [] symTable str = str
showSymTable (a:alphabet) symTable str = showSymTable alphabet symTable (addToPrintStr (H.lookup a symTable) a str)

addToPrintStr :: Maybe TMInstruction -> String -> String -> String
addToPrintStr (Just (Instruction symbol dir nextState)) readSym str = (str ++ "(read " ++ show readSym ++ ", write " ++ show symbol ++ ", move " ++ show dir ++ ", next state: " ++ show nextState ++ ") ")
addToPrintStr Nothing readSym str = str

showInstruction machine alphabet tape startState position = showInstructionHelper (H.lookup startState machine) tape position

showInstructionHelper (Just (State symTable)) tape position = (showInstructionHelper2 (H.lookup (tape!!position) symTable) (tape!!position))

showInstructionHelper2 (Just (Instruction writeSymbol dir nextState)) readSymbol = ("Preforming instruction: (read " ++ show readSymbol ++ ", write " ++ show writeSymbol ++ ", move " ++ show dir ++ ", next state: " ++ show nextState ++ ")")


-- From: http://stackoverflow.com/questions/10133361/haskell-replace-element-in-list
replaceAtIndex :: Int -> String -> [String] -> [String]
replaceAtIndex n item ls = a ++ (item:b) where (a, (_:b)) = splitAt n ls
