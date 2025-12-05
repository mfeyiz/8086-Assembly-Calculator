# MicroprocessorProject - Simple 8086 Calculator

This repository contains two small 8086 assembly calculator programs intended to run under DOS (or an emulator like DOSBox / emu8086).

- `MicroProcessorProject_v1.asm` – **Version 1**: two-number calculator using string input and conversion.
- `MicroProcessorProject_v2.asm` – **Version 2**: multi-number calculator with repeated operations on a list of values.

---

## Version 1 – `MicroProcessorProject_v1.asm`

**Purpose:**

- Read two (positive) decimal integers as strings from the keyboard.
- Let the user choose an operation using digits:
  - `1` → addition ( + )
  - `2` → subtraction ( - )
  - `3` → multiplication ( * )
  - `4` → division ( / )
- Perform the chosen operation and print the result as a decimal string.
- Detect division by zero and print an error message.

**Key implementation details:**

- Uses DOS function `0Ah` (buffered input) to read lines into input buffers `num1`, `num2`, and `op_buf`.
- `atoi` converts an ASCII decimal string into a 16-bit integer in `AX`.
- `itoa` converts an unsigned 16-bit value in `AX` into an ASCII decimal string stored in `result`, terminated with `$` for DOS function `09h`.
- Arithmetic results are stored in `BX` before being passed to `itoa`.

**How to run (example with emu8086 / DOSBox):**

1. Assemble the file to a `.COM` (or `.EXE`) program.
2. Run from DOS:

```bat
MicroProcessorProject_v1.com
```

3. Follow the prompts:
   - Enter first number
   - Enter second number
   - Enter operation (1–4)

---

## Version 2 – `MicroProcessorProject_v2.asm`

**Purpose:**

- Let the user enter **multiple integers** (positive or negative), one by one.
- The user finishes the list by entering `0`.
- Then the user selects an operation:
  - `+`, `-`, `*`, `/` or `Q`/`q` to quit.
- The selected operation is applied across the whole list of numbers:
  - Addition: sum of all numbers.
  - Subtraction: first number minus all following numbers.
  - Multiplication: product of all numbers.
  - Division: sequential division (first number divided by each following value).
- The result is printed in decimal and the program returns to the main loop to start again.

**Key implementation details:**

- Data is stored in a `numbers` array (`dw 100 dup(?)`). `count` stores how many words are used.
- `read_number` reads a possibly negative multi-digit integer from the keyboard using repeated `int 21h / AH=1` calls.
  - Supports an optional leading `'-'` sign.
  - Builds the value in base-10 using `mul ten` and adding each digit.
- `write_number` prints a signed decimal value from `AX`:
  - Prints `'-'` for negative numbers, then prints the absolute value digit by digit.
- The main control flow:
  1. Clear `count`.
  2. Loop asking for numbers until `0` is entered.
  3. Ask for an operation or `Q` to quit.
  4. Run the appropriate loop (`add_loop`, `sub_loop`, `mul_loop`, `div_loop`) over the `numbers` array.
  5. Print the result and restart.

**How to run:**

1. Assemble `MicroProcessorProject_v2.asm` with your 8086 assembler.
2. Run the resulting program from DOS:

```bat
MicroProcessorProject_v2.com
```

3. Example session:
   - Enter several numbers (e.g. `5`, `-2`, `3`, `0` to finish the list).
   - Choose an operation (`+`, `-`, `*`, `/`).
   - See the printed result.
   - The program returns to the beginning and lets you start a new calculation or quit with `Q`.

---

## Notes

- Both versions assume a 16-bit DOS environment (e.g. DOSBox, emu8086) and use `int 21h` for all I/O.
- Version 1 focuses on string-to-integer and integer-to-string conversion with a fixed two-operand model.
- Version 2 focuses on handling a list of integers, negative numbers, and repeated operations over an array.
