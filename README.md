# Haskell Turing Machine
A Turing Machine simulator written in Haskell

Currently under development.

###Usage

Load the program into a Haskell interpreter. I am using GHCi.

```sh
ghci Turing.hs
```

Input the Turing Machine specifications:
- Tape alphabet (String list)
- Initial tape (String list)
- Machine definition with states

Note that the "HALT" state is reserved.

The Machine definition is a HashMap where the keys are states labeled with Strings, and the values are States.

The State definition is a HashMap where the keys are the symbols read in from the current tape position, and the values are Instructions.

The Instruction definition consists of:
- A String, which is the label to write to the tape's current position.
- A Direction, either TapeRight or TapeLeft to move the tape after writing
- A String, which is the label of the next state. "HALT" should be entered when the program should terminate.


The example below is a machine which adds 1 to the binary number on the tape. From: https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/turing-machine/four.html

```haskell
let alphabet = ["", "0", "1"]
let tape = ["1", "1", "1"]
:{
let machine = H.fromList [
                        ("0",State (H.fromList [("",Instruction "" TapeRight "1"), ("0",Instruction "0" TapeLeft "0"), ("1",Instruction "1" TapeLeft "0")])),
                        ("1",State (H.fromList [("",Instruction "1" TapeLeft "2"), ("0",Instruction "1" TapeRight "2"), ("1",Instruction "0" TapeRight "1")])),
                        ("2",State (H.fromList [("",Instruction "" TapeRight "HALT"), ("0",Instruction "0" TapeLeft "2"), ("1",Instruction "1" TapeLeft "2")]))
                      ]
:}
```

After the alphabet, tape, and machine are defined the program can be run with:

```haskell
runVerbose machine alphabet tape startState
```

Where startState is a String with the initial state's label.

###Example run

The asterisk shows the current position of the head on the tape.

```haskell
*Main> let alphabet = ["", "0", "1"]
*Main> let tape = ["1", "1", "1"]
*Main> :{
*Main| let machine = H.fromList [
*Main|                         ("0",State (H.fromList [("",Instruction "" TapeRight "1"), ("0",Instruction "0" TapeLeft "0"), ("1",Instruction "1" TapeLeft "0")])),
*Main|                         ("1",State (H.fromList [("",Instruction "1" TapeLeft "2"), ("0",Instruction "1" TapeRight "2"), ("1",Instruction "0" TapeRight "1")])),
*Main|                         ("2",State (H.fromList [("",Instruction "" TapeRight "HALT"), ("0",Instruction "0" TapeLeft "2"), ("1",Instruction "1" TapeLeft "2")]))
*Main|                       ]
*Main| :}
*Main> runVerbose machine alphabet tape "0"
*Main> runVerbose machine alphabet tape "0"
Step 0. Tape: [*"1", "1", "1"]
Step 0. On state "0"
Step 0. Preforming instruction: (read "1", write "1", move TapeLeft, next state: "0")

Step 1. Tape: ["1", *"1", "1"]
Step 1. On state "0"
Step 1. Preforming instruction: (read "1", write "1", move TapeLeft, next state: "0")

Step 2. Tape: ["1", "1", *"1"]
Step 2. On state "0"
Step 2. Preforming instruction: (read "1", write "1", move TapeLeft, next state: "0")

Step 3. Tape: ["1", "1", "1", *""]
Step 3. On state "0"
Step 3. Preforming instruction: (read "", write "", move TapeRight, next state: "1")

Step 4. Tape: ["1", "1", *"1", ""]
Step 4. On state "1"
Step 4. Preforming instruction: (read "1", write "0", move TapeRight, next state: "1")

Step 5. Tape: ["1", *"1", "0", ""]
Step 5. On state "1"
Step 5. Preforming instruction: (read "1", write "0", move TapeRight, next state: "1")

Step 6. Tape: [*"1", "0", "0", ""]
Step 6. On state "1"
Step 6. Preforming instruction: (read "1", write "0", move TapeRight, next state: "1")

Step 7. Tape: [*"", "0", "0", "0", ""]
Step 7. On state "1"
Step 7. Preforming instruction: (read "", write "1", move TapeLeft, next state: "2")

Step 8. Tape: ["1", *"0", "0", "0", ""]
Step 8. On state "2"
Step 8. Preforming instruction: (read "0", write "0", move TapeLeft, next state: "2")

Step 9. Tape: ["1", "0", *"0", "0", ""]
Step 9. On state "2"
Step 9. Preforming instruction: (read "0", write "0", move TapeLeft, next state: "2")

Step 10. Tape: ["1", "0", "0", *"0", ""]
Step 10. On state "2"
Step 10. Preforming instruction: (read "0", write "0", move TapeLeft, next state: "2")

Step 11. Tape: ["1", "0", "0", "0", *""]
Step 11. On state "2"
Step 11. Preforming instruction: (read "", write "", move TapeRight, next state: "HALT")

Step 12. Tape: ["1", "0", "0", *"0", ""]
Step 12. HALTING Program Complete.
*Main>
```
