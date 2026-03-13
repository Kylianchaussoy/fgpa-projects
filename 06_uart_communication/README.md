# VHDL UART Controller for FPGA

## Overview
This project implements a full-duplex UART (Universal Asynchronous Receiver-Transmitter) communication system in VHDL. The controller enables serial communication between an FPGA and a host computer, allowing data to be sent and received through a standard terminal application like PuTTY.

The system is designed to:
*   **Transmit** an 8-bit data value set by the onboard slide switches when a push-button is pressed.
*   **Receive** an 8-bit data value from the host computer and display it on the onboard LEDs.

## Board
This project is designed and verified on the Digilent Basys 3 Artix-7 FPGA board.

## Acknowledgements & Inspiration
The foundational architecture for the UART receiver and transmitter was inspired by Alexey Sudbin's open-source UART controller project, available [here on Hackster.io](https://www.hackster.io/alexey-sudbin/uart-interface-in-vhdl-for-basys3-board-eef170).

