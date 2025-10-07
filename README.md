# Digital Design and FPGA Implementation Projects

This repository contains a comprehensive collection of digital design projects implemented in Verilog/SystemVerilog and C, targeting FPGA platforms. The projects demonstrate various aspects of digital system design, from basic arithmetic operations to complex machine learning implementations.

## Project Overview

The repository is organized into seven main project directories, each focusing on different aspects of digital design and FPGA implementation:

### 1. Generic Adder-Subtractor
Implementation of configurable N-bit adder-subtractor circuits using different design methodologies:
- **Continuous Assignment**: Structural implementation using continuous assignments
- **Gate Level**: Low-level gate implementation
- **Procedural Constructs**: Behavioral implementation using always blocks
- **Test Benches**: Comprehensive testing for 4-bit, 6-bit, and 8-bit configurations

### 2. Single & Multi-Cycle Adder-Subtractor
Advanced adder-subtractor implementations with timing control:
- **Single Cycle**: One-cycle completion implementation
- **Multi-Cycle**: N-cycle implementation for pipeline optimization
- **Simulation Scripts**: ModelSim/QuestaSim scripts for automated testing
- **Waveform Analysis**: Pre-configured wave viewing scripts

### 3. Pipelined Implementation of Adder-Subtractor
High-performance pipelined adder-subtractor design:
- **Pipeline Architecture**: Multi-stage pipeline for improved throughput
- **Simulation Environment**: Complete testbench and simulation setup
- **Performance Analysis**: Timing and throughput optimization

### 4. Pipelined TEA Implementation
Hardware implementation of the Tiny Encryption Algorithm (TEA):
- **C Reference**: Software reference implementation for verification
- **Pipelined Hardware**: Verilog implementation with pipeline optimization
- **Encryption Engine**: 32-round TEA encryption with configurable keys
- **Test Vectors**: Comprehensive test cases with known plaintext/ciphertext pairs

### 5. HDL Implementation of TEA on Xilinx Board
Complete TEA implementation for Xilinx FPGA platforms:
- **UART Communication**: Serial communication interface
- **Register Files**: 8-bit register implementation
- **Loop-back Device**: Hardware testing and verification
- **Board Integration**: Xilinx-specific implementation details

### 6. Serial 32-bit Adder with AXI-Lite
AXI4-Lite compliant 256-bit adder implementation:
- **AXI4-Lite Slave**: FPGA-side AXI slave implementation
- **Zynq Integration**: ARM processor integration code
- **Memory-Mapped Interface**: Register-based control and data interface
- **Random Testing**: Automated random test generation

### 7. MNIST FCN Implementation on FPGA
Machine Learning on FPGA - Fully Connected Network for MNIST digit recognition:
- **Neural Network**: 784→64→32→10 fully connected architecture
- **Memory Management**: Dedicated weight and bias memory blocks
- **AXI Integration**: AXI4-Lite interface for processor communication
- **Hardware Acceleration**: Custom multiplication and ReLU functions
- **Digit Classification**: Real-time MNIST digit recognition

## Technology Stack

- **HDL Languages**: Verilog, SystemVerilog
- **Software Languages**: C
- **FPGA Platforms**: Xilinx (Zynq, 7-series)
- **Simulation Tools**: ModelSim/QuestaSim
- **Synthesis Tools**: Xilinx Vivado
- **Communication Protocols**: AXI4-Lite, UART
- **Development Environment**: Xilinx SDK/Vitis

## Key Features

### Digital Design Concepts
- **Arithmetic Operations**: Addition, subtraction with carry/borrow handling
- **Pipeline Design**: Multi-stage pipeline architectures
- **Memory Systems**: Block RAM, distributed memory
- **State Machines**: Complex FSM implementations
- **Timing Optimization**: Clock domain management and timing closure

### FPGA-Specific Features
- **Resource Utilization**: Efficient use of LUTs, DSPs, and BRAMs
- **IP Integration**: Xilinx IP core integration
- **Constraint Management**: Timing and placement constraints
- **Hardware/Software Co-design**: ARM+FPGA implementations

### Communication Interfaces
- **AXI4-Lite**: Industry-standard on-chip interconnect
- **UART**: Serial communication for debugging and data transfer
- **Memory-Mapped I/O**: Register-based control interfaces

## Getting Started

### Prerequisites
- Xilinx Vivado Design Suite (2018.3 or later)
- ModelSim/QuestaSim for simulation
- Xilinx SDK/Vitis for software development
- Compatible Xilinx FPGA development board (for hardware testing)

### Project Structure
Each project directory contains:
- **Source Files**: Verilog/SystemVerilog HDL files
- **Test Benches**: Comprehensive verification environments
- **Simulation Scripts**: Automated simulation setup
- **Documentation**: Project-specific README files
- **Constraints**: Timing and placement constraint files (where applicable)

### Simulation
Most projects include simulation scripts (`run.do`, `wave.do`) for ModelSim/QuestaSim:
```bash
# Navigate to project directory
cd "1. Generic Adder-Subtractor"
# Run simulation
vsim -do run.do
```

### Synthesis and Implementation
Projects targeting FPGA hardware include Vivado project files and can be synthesized using:
1. Open Vivado
2. Create new project or open existing project file
3. Add source files from the respective project directory
4. Run synthesis and implementation
5. Generate bitstream for hardware deployment

## Project Complexity Progression

The projects are arranged in increasing complexity:

1. **Basic Arithmetic** → **Timing Control** → **Pipeline Design**
2. **Encryption Algorithms** → **Board Integration** → **Communication Protocols**
3. **Machine Learning** → **Advanced Memory Management** → **System Integration**

## Hardware Requirements

### Minimum FPGA Resources
- **LUTs**: 1000+ (varies by project)
- **Flip-Flops**: 500+ (varies by project)
- **Block RAM**: 1+ BRAM tiles (for memory-intensive projects)
- **DSP Slices**: 1+ (for multiplication-heavy projects)

### Recommended Development Boards
- Xilinx Zynq-7000 series (ZedBoard, Pynq-Z1, Zybo)
- Xilinx Artix-7 series (Basys 3, Nexys 4)
- Any Xilinx board with sufficient resources

## Contributing

When contributing to this repository:
1. Follow consistent coding style and documentation standards
2. Include comprehensive test benches for new modules
3. Update relevant README files
4. Ensure all projects simulate successfully
5. Test on hardware when possible

## License

This project is intended for educational and research purposes. Please refer to individual project directories for specific licensing information.

## Contact

For questions, issues, or contributions, please refer to the project maintainer or create an issue in the repository.

---

*This repository demonstrates the progression from basic digital design concepts to advanced FPGA implementations, providing a comprehensive learning path for digital system design and FPGA development.*