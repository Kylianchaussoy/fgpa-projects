# VHDL SPI Controller for FPGA

## Overview
This project implements a full-duplex SPI (Serial Peripheral Interface) communication system in VHDL. The controller enables synchronous serial communication between an SPI master and an SPI slave, both instantiated on the same FPGA, connected internally via shared SPI bus signals.
 
The SPI operates in **Mode 0** (CPOL = 0, CPHA = 0) with an 8-bit data format. It features a loopback mechanism to demonstrate functionality effectively. The system uses switches 0-7 on the FPGA board to set the transmission data for the SPI master, while the received data is displayed on LEDs 0-7, showcasing the data received from the slave.

## Board
This project is designed and verified on the Digilent Basys 3 Artix-7 FPGA board.
