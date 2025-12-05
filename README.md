# 5-Stage Pipelined RISC-V CPU
This repository contains a Verilog implementation of a 5-stage pipelined RISC-V CPU. The processor supports hazard detection, data forwarding, and is designed to be validated against a series of instruction test cases.

## Features

  * **5-Stage Pipeline:** Implements Instruction Fetch (IF), Instruction Decode (ID), Execution (EX), Memory Access (MEM), and Write Back (WB) stages.
  * **Hazard Handling:**
      * **Hazard Detection Unit:** Detects load-use hazards to insert stalls and bubbles (NoOPs).
      * **Forwarding Unit:** Solves data hazards by forwarding results from MEM and WB stages back to the EX stage.
      * **Branch handling:** Flushes the IF stage when a branch is taken.
  * **Simulation & Synthesis:** Includes configurations for simulation via Icarus Verilog and synthesis checking via Yosys.
  * 
## Prerequisites

To run the project as intended, you need:

  * **Docker** (Recommended)
  * **Icarus Verilog** (for manual local simulation)
  * **Yosys** (for synthesis checking)

## Usage

### Using Docker (Recommended)

The project includes a `Makefile` to simplify running the environment using Docker Compose.

1.  **Run the project:**

    ```bash
    make run
    ```

    This command triggers `docker compose up`.

2.  **Clean up:**

    ```bash
    make clean
    ```

    This removes the containers and the local image.

### Manual Simulation (Local)

If you prefer to run the simulation locally without Docker, you can follow the steps defined in the `judge.yaml` configuration:

1.  **Compile the design:**

    ```bash
    iverilog -g2012 -o cpu code/tb/*.v code/supplied/*.v code/src/*.v
    ```

2.  **Run a specific test case:**
    Copy the desired instruction file to `instruction.txt` and run the simulation.

    ```bash
    cp testcases/instruction_1.txt instruction.txt
    vvp ./cpu
    ```

3.  **Verify Output:**
    The simulation generates an `output.txt`. Compare this with the expected output.

    ```bash
    diff output.txt testcases/output_1.txt
    ```
