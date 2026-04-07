# 8-bit Modular VHDL CPU

## Overview
This project implements a custom 8-bit RISC-style processor in VHDL, optimized for implementation on a Basys FPGA board. The architecture features a 16-bit instruction word, a 4-register bank, and a dedicated hardware visualization suite for real-time debugging.

## Technical Specifications
*   **Data Width**: 8-bit.
*   **Instruction Width**: 16-bit.
*   **Registers**: 4 general-purpose 8-bit registers (R0–R3).
    *   *Note*: **R0** is hardwired to `0x00` for common operations.
*   **Program Counter**: 8-bit (supports increment, jump, and reset).
*   **Clocking**: Includes a clock divider to slow down execution for visual observation on the FPGA.

## Instruction Set Architecture (ISA)
The Instruction Decoder handles 4-bit opcodes and generates control signals for the following operations:

| Instruction | Type | Description |
| :--- | :--- | :--- |
| **ADD** | Arithmetic | Add Rs1 and Rs2, store in Rd |
| **SUB** | Arithmetic | Subtract Rs2 from Rs1, store in Rd |
| **AND** | Logical | Bitwise AND of Rs1 and Rs2 |
| **OR** | Logical | Bitwise OR of Rs1 and Rs2 |
| **XOR** | Logical | Bitwise XOR of Rs1 and Rs2 |
| **NOT** | Logical | Bitwise NOT of Rs1, store in Rd |
| **LDI** | Memory | Load 8-bit Immediate (Imm8) into Rd |
| **MOV** | Data | Move value from Rs1 to Rd |
| **JMP** | Branch | Unconditional jump to address in Imm8 |
| **BEQ** | Branch | Branch to Imm8 if Rs1 equals Rs2 |
| **HLT** | Control | Halt CPU execution |

## Instruction Format (16-bit)
| Bits | Field | Description |
| :--- | :--- | :--- |
| `[15:12]` | **OPCODE** | 4-bit operation identifier |
| `[11:10]` | **Rd** | Destination register (2 bits) |
| `[9:8]`   | **Rs1** | Source register 1 (2 bits) |
| `[7:4]`   | **Rs2** | Source register 2 (Uses bits `[5:4]`) |
| `[7:0]`   | **Imm8** | 8-bit Immediate value (for LDI, JMP, BEQ) |

## Hardware Mapping (Basys Board)
The `basys3.vhd` top module maps the internal CPU state to the hardware peripherals as follows:

*   **Seven-Segment Display**:
    *   **Left Two Digits**: Displays the current **Program Counter (PC)** value.
    *   **Right Two Digits**: Displays the current **ALU Result**.
    *   **Decimal Point (DP)**: Lights up when the CPU reaches a **HALT (`HLT`)** state.
*   **LEDs**:
    *   **Left 8 LEDs**: Displays the 8-bit value currently held in **Rs1**.
    *   **Right 8 LEDs**: Displays the 8-bit value currently held in **Rs2**.

## Component Breakdown
*   **`basys3_top.vhd`**: Top-level structural design and pin mapping.
*   **`instruction_decoder.vhd`**: Logic for instruction decomposition and control signal generation.
*   **`alu.vhd`**: 8-bit unit supporting ADD, SUB, AND, OR, XOR, and NOT.
*   **`register_file.vhd`**: Dual-read, single-write port register bank (R0-R3).
*   **`program_counter.vhd`**: 8-bit address management with jump logic.
*   **`clk_divider.vhd`**: Frequency scaler for hardware visualization.
*   **`seven_seg.vhd`**: 16-bit to 7-segment hex decoder and multiplexer.
