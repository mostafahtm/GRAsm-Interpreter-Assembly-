# GRAsm-Interpreter (Assembly)

This repository contains the implementation of the GRAsm-Interpreter, a project for interpreting bytecode programs in x86-64 Assembly. The interpreter simulates a "GRA machine" with virtual registers, supporting various operations and handling errors that may occur during execution.

---

## **Repository Structure**

- `GRA-Aufgabenstellung.jpg`: Task description for the GRAsm-Interpreter.
- `grasm_interpreter.asm`: The Assembly code for the interpreter implementation.
- `README.md`: Documentation for the project.
---

## **Features**

- Implements a virtual 64-bit register system:
  - General-purpose registers: `r0-r7`
  - Special-purpose registers: `ip` (Instruction Pointer), `ac` (Accumulator), `sp` (Stack Pointer)
- Supports a range of instructions including arithmetic operations, memory management, function calls, and jumps.
- Comprehensive error handling for invalid instructions, out-of-bounds memory access, and simultaneous faults.

---

This project was developed as part of an advanced assembly programming task, requiring all instructions to be implemented and tested for correct behavior. Feel free to explore the repository and raise issues for further clarification or support.
