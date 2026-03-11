# Traffic Light Controller FPGA Project

## Overview
This project implements a traffic light controller using FPGA. The system controls the operation of traffic lights for a two-directional intersection, utilizing a finite state machine (FSM) to manage the states of the traffic lights. The controller cycles through various states, including green lights for one direction, red lights for the other, and yellow lights to signal changes. Both directions will display red lights simultaneously before one direction transitions to green, mimicking real-life traffic control behavior.

The LED outputs represent the traffic lights, with `led1` indicating the lights for one direction and `led2` for the opposite direction. The timing for each state is controlled by a clock divider to create a slow clock signal, allowing for realistic traffic light timing. The design includes predefined delays for green, yellow, and red light durations, ensuring proper traffic flow and safety at intersections.

## Board
This project is implemented on the Basys3 FPGA board.
