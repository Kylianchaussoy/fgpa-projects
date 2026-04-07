# I2C Master-Slave Communication System

A robust VHDL implementation of the I2C protocol featuring a Master controller, a Slave device, and a top-level structural wrapper.

## Project Structure

- **i2c_master.vhd**: Handles the I2C state machine, start/stop conditions, and data bit-shifting.
- **i2c_slave.vhd**: Responds to address `0000001` and supports clock stretching.
- **i2c_controller.vhd**: The top-level entity that connects the Master and Slave, simulates the open-drain bus, and debounces inputs.

## Features

- **Clock Stretching**: The Slave can hold SCL low to throttle the Master.
- **Burst Mode**: Enable `burst_en` to perform multi-byte transfers without a stop condition.
- **Wired-AND Logic**: Internal logic simulates the physical I2C pull-up resistor behavior.

## Board
This project is implemented on the Basys3 FPGA board.
