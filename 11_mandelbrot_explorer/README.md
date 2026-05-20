# Basys3 FPGA Mandelbrot Explorer

A real-time Mandelbrot Set explorer implemented in VHDL for the Digilent Basys3 FPGA. This project calculates and displays the Mandelbrot fractal on a VGA monitor, allowing the user to seamlessly pan and zoom using the onboard switches and push buttons.

![Mandelbrot Example 1](images/image1.png)
![Mandelbrot Example 2](images/image2.jpg)

## Features

*   **Dedicated Hardware Pipeline:** The fractal is generated natively in custom digital logic, avoiding the overhead of software execution on a CPU.
*   **Interactive Controls:** Fully debounced button inputs allow smooth panning and zooming.
*   **Dynamic Zoom Limits:** Built-in safeguards to prevent zooming past the mathematical precision limits of the system.
*   **VGA Display Output:** Standard 640x480 @ 60Hz display output via the Basys3 VGA port.
*   **Indexed Color Mapping:** Uses a 4-bit BRAM frame buffer mapped to a 12-bit RGB palette, saving massive amounts of memory while still producing vibrant, psychedelic fractal bands and a true-black center.

## Technical Implementation

### Fixed-Point Arithmetic (Q4.24)
To calculate the fractal coordinates $Z_{n+1} = Z_n^2 + C$ in hardware without the massive overhead of floating-point units, this project utilizes **Q4.24 signed fixed-point arithmetic**:
* The Mandelbrot escape condition requires checking if the magnitude exceeds a radius of 2, which means calculating if $X^2 + Y^2 > 4$. A Q2 format can only represent values up to +1.99. Therefore, 4 integer bits (providing a range of -8 to +7) are necessary to safely represent the number 4 and handle intermediate additions without overflow.
*  **24 Fractional Bits:** Provides extremely high precision, allowing the user to zoom deep into the fractal before experiencing pixelation.

### System Architecture
The system consists of several distinct VHDL modules:
1.  **VGA Controller:** Generates the `h_sync`, `v_sync`, and raw pixel coordinates for a 640x480 display.
2.  **Coordinate Mapper:** Translates the raw X/Y screen pixels from the VGA controller into the high-precision Q4.24 complex plane coordinates based on current pan and zoom levels.
3.  **Mandelbrot Core:** The computational pipeline that iterates the math up to 64 times per pixel to determine how quickly the sequence escapes.
4.  **Color Mapper:** Takes the escape iteration count and translates it into a 16-color "zebra-stripe" palette, forcing points trapped inside the set to display as Black.
5.  **Frame Buffer (BRAM):** A dual-port memory module. The system writes 4-bit color indices to the buffer, while the VGA controller reads from it at 25MHz to draw to the screen. 
6.  **Debounce & UI Logic:** Filters electrical noise from the mechanical buttons and manages system states.

### Hardware Optimizations
To achieve maximum performance and FPGA resource efficiency, the `mandelbrot_core` utilizes several hardware-specific design principles:

* **Hardware Resource Sharing:** The squared values ($Z_{re}^2$ and $Z_{im}^2$) are needed twice per iteration: once to check if the point escaped ($Z_{re}^2 + Z_{im}^2 \ge 4$), and once to calculate the next real value. By calculating these massive 28-bit squares just once and reusing them, the design reduces the required number of hardware multipliers from five down to three.

* **DSP Conservation (Bit-Shifting):** Calculating the next imaginary value requires multiplying by two ($2 \times Z_{re} \times Z_{im} + C_{im}$). Instead of wasting a physical hardware multiplier (DSP slice) to multiply by 2, the design uses a logical left shift (`shift_left`). This performs the math instantly for free using simple wire routing.

* **Multi-Cycle Timing:** 28-bit fixed-point multiplication takes time to process and can slow down the FPGA's clock speed. To fix this, the state machine uses a dedicated `WAIT_MUL` state. This gives the multipliers an extra clock cycle to finish their math before moving on, preventing timing errors.


## Controls

The project uses the onboard push buttons and switches of the Basys3 board:

| Input | Function |
| :--- | :--- |
| **BTNU** | Pan Up |
| **BTND** | Pan Down |
| **BTNL** | Pan Left |
| **BTNR** | Pan Right |
| **BTNC + SW1 (Down/0)** | Zoom In |
| **BTNC + SW1 (Up/1)** | Zoom Out |
| **SW2** | System Reset / Recenter |
