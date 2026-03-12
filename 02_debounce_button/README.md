# FPGA Hardware Debouncer & Tester

## Overview
This project implements a highly reliable, hardware-based **button debounce module** for FPGAs, alongside a **top-level tester module** to visually prove its effectiveness. 

This system solves button bouncing by employing synchronization D flip-flops (to prevent metastability), a timer counter (to wait out the mechanical bounce), and an edge-detector (to output exactly one clean pulse). The top-level tester records both the "clean" presses and the "raw/bouncy" presses simultaneously. The results are visualized on 16 LEDs, allowing for a clear, real-time comparison between the two methods.

## Board
This project is implemented on the Basys3 FPGA board.

## Acknowledgements & Inspiration
The architecture of the debounce logic was inspired by Alexey Sudbin's open-source UART_controller project, available [here on Hackster.io](https://www.hackster.io/alexey-sudbin/uart-interface-in-vhdl-for-basys3-board-eef170#code).

