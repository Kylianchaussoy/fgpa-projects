# RV32I Soft Core

32-bit RISC-V soft microprocessor written in VHDL. This core implements the **RV32I Base Integer Instruction Set** using a classic 5-stage pipeline. 

## Key Features

* **Architecture:** 32-bit RISC-V (RV32I)
* **Pipeline:** 5-Stage (Fetch, Decode, Execute, Memory, Writeback)
* **Data Hazard Resolution:** Full internal forwarding (EX-to-EX and MEM-to-EX) resolving Read-After-Write (RAW) hazards without unnecessary stalls.
* **Control Hazard Resolution:** Dynamic pipeline flushing on taken branches/jumps.
* **Load-Use Stall Logic:** Dedicated Hazard Unit detects memory-to-register dependencies and stalls the pipeline accordingly.

## File Structure

* `pipelined_cpu.vhd` - The top-level entity wiring the pipeline stages, multiplexers, and registers.
* `instruction_decoder.vhd` - Translates raw 32-bit instructions into control signals.
* `alu.vhd` - Arithmetic Logic Unit supporting ADD, SUB, AND, OR, XOR, shifts, etc.
* `register_file.vhd` - 32x32-bit dual-read, single-write register file.
* `forwarding_unit.vhd` - Resolves data hazards by routing data directly to the ALU.
* `hazard_unit.vhd` - Detects Load-Use hazards and asserts the `stall` signal.
* `branch_unit.vhd` - Evaluates branch conditions (BEQ, BNE, BLT, BGE, etc.).
* `instruction_memory.vhd` - Synchronous ROM/BRAM implementation with stall-enable protection.
* `data_memory.vhd` - Read/Write memory for Load/Store operations.
* `rv32i_pkg.vhd` - VHDL package containing custom types (e.g., `alu_op_t`, `branch_op_t`) and constants.

## RV32I Implementation Details

This core supports the full base integer instruction set:

* **Arithmetic & Logic:** Full support for R-type and I-type instructions including `ADD`, `SUB`, `SLT`, `SLTU`, `XOR`, `OR`, `AND`, and all logical shifts (`SLL`, `SRL`, `SRA`).
* **Immediate Handling:** Efficient sign-extension for 12-bit immediates and support for 20-bit upper immediates via `LUI` and `AUIPC`.
* **Memory Access:** 
    * Support for Load/Store instructions (`LW`, `SW`).
    * Byte and Halfword handling (`LB`, `LH`, `LBU`, `LHU`, `SB`, `SH`) via `funct3` decoding in the Data Memory stage.
* **Control Flow:** 
    * Unconditional jumps: `JAL` and `JALR`.
    * Conditional branches: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`.
* **Synchronous Memory Optimization:** 
    * **Stall Protection:** Uses a memory enable (`en`) signal tied to the Hazard Unit to prevent instruction loss during pipeline stalls.
    * **Latency Compensation:** Implements a `flush_delay` mechanism to handle the 1-cycle latency of synchronous Block RAM, ensuring the correct instruction is fetched after a branch flush.
