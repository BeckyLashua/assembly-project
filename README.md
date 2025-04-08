# Designing Low-Level I/O Procedures (Project6.asm)

**Author:** Rebecca Lashua  
**Course:** CS271 – Computer Architecture & Assembly Language  
**Last Modified:** June 10, 2020  
**Institution:** Oregon State University

---

## 📝 Project Overview

This project demonstrates low-level I/O procedure design in x86 assembly (MASM) by implementing custom input/output operations without relying on high-level library functions.

The program prompts the user to enter **10 signed 32-bit integers**, validating each input using custom `readInt` and `writeInt` procedures. All input/output functionality—including string reads and displays—is handled through custom `getString` and `displayString` macros. Parameters are passed through the stack.

---

## 🧠 Key Features

- Custom **input validation** and **numeric conversion**
- Manual handling of **string-to-integer** and **integer-to-string** logic
- Displays:
  - List of entered numbers
  - Their **sum**
  - Their **rounded average**
- Uses stack-based parameter passing for procedure calls
- All output formatting and input handling done at the assembly level

---

## 🔧 Built With

- **Assembly Language (MASM)**
- **Irvine32 Library**
- **Windows OS (32-bit execution environment)**

---

## 📂 File Breakdown

- `main PROC`: Program control flow
- `getString` / `displayString`: Custom macros for handling user text input/output
- `readVal`, `convertStrToNum`, `writeVal`: Procedures for reading, converting, and displaying signed integers
- `fillArray`: Collects valid user inputs into an array
- `calculateSum` / `calculateAvg`: Arithmetic logic for the array
- `displayArray` / `displayResult`: Handles final output formatting
- `introduction` / `farewell`: User-facing welcome and exit messages

---

## 💡 Learning Goals

- Practice stack-based parameter passing
- Reinforce understanding of signed number representation
- Apply logic for string manipulation, input parsing, and integer formatting
- Develop custom input/output routines from scratch in assembly

---

## 📌 Notes

- All data validation and formatting is performed manually in assembly—no built-in conversions are used.
- Input must fit within the range of a 32-bit signed integer (`-2,147,483,648` to `2,147,483,647`).
- The project was developed in a 32-bit Windows environment using the Irvine32 library.

---

## 🎓 Academic Integrity

This project was completed individually as part of the coursework for CS271 at Oregon State University. Please do not submit this code or use it as a substitute for your own work in any academic setting.

