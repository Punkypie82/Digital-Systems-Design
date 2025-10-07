# Serial 32-bit Adder with AXI-Lite

This directory contains a complete hardware-software co-design implementation of a 256-bit adder using AXI4-Lite protocol for communication between an ARM processor and FPGA fabric, demonstrating modern SoC design principles.

## Overview

This project showcases a professional approach to FPGA-based arithmetic acceleration using industry-standard communication protocols. The design implements a 256-bit adder that operates serially (32 bits per clock cycle) and is controlled via AXI4-Lite memory-mapped registers, making it suitable for integration into Zynq-based systems.

### System Architecture

```
ARM Processor ←→ AXI4-Lite Interconnect ←→ Custom AXI Slave ←→ Serial Adder
```

**Key Components**:
1. **AXI4-Lite Slave**: Hardware interface implementing AXI protocol
2. **Serial Adder Engine**: 256-bit addition with 32-bit datapath
3. **ARM Software**: C application for testing and control
4. **Memory-Mapped Interface**: Register-based control and data access

## Implementation Details

### 1. AXI4-Lite Slave Controller (`axi4_lite_slave.v`)

**Professional AXI Implementation**
- **Full AXI4-Lite Compliance**: Implements all required channels
- **Memory-Mapped Registers**: 32 × 32-bit register array
- **State Machine Control**: Robust protocol handling
- **Integrated Arithmetic Engine**: Built-in 256-bit serial adder

**AXI4-Lite Interface Signals**:

#### Global Signals
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `ACLK` | Input | 1-bit | AXI clock |
| `ARESETN` | Input | 1-bit | AXI active-low reset |

#### Read Address Channel
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `S_ARADDR` | Input | 32-bit | Read address |
| `S_ARVALID` | Input | 1-bit | Read address valid |
| `S_ARREADY` | Output | 1-bit | Read address ready |

#### Read Data Channel
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `S_RDATA` | Output | 32-bit | Read data |
| `S_RRESP` | Output | 2-bit | Read response |
| `S_RVALID` | Output | 1-bit | Read data valid |
| `S_RREADY` | Input | 1-bit | Read data ready |

#### Write Address Channel
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `S_AWADDR` | Input | 32-bit | Write address |
| `S_AWVALID` | Input | 1-bit | Write address valid |
| `S_AWREADY` | Output | 1-bit | Write address ready |

#### Write Data Channel
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `S_WDATA` | Input | 32-bit | Write data |
| `S_WSTRB` | Input | 4-bit | Write strobes |
| `S_WVALID` | Input | 1-bit | Write data valid |
| `S_WREADY` | Output | 1-bit | Write data ready |

#### Write Response Channel
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `S_BRESP` | Output | 2-bit | Write response |
| `S_BVALID` | Output | 1-bit | Write response valid |
| `S_BREADY` | Input | 1-bit | Write response ready |

### 2. Register Memory Map

**32 × 32-bit Register Array**:

| Address Offset | Register | Purpose | Access |
|----------------|----------|---------|--------|
| 0x00-0x1C | A[7:0] | 256-bit Operand A | R/W |
| 0x20-0x3C | B[7:0] | 256-bit Operand B | R/W |
| 0x40 | START | Start computation | W |
| 0x44-0x60 | SUM[7:0] | 256-bit Result | R |
| 0x64 | DONE | Completion flag | R |
| 0x68-0x7C | Reserved | Future use | - |

**Register Layout**:
```verilog
// Input operands (256 bits each)
A = {register[7], register[6], ..., register[0]};  // A[255:0]
B = {register[15], register[14], ..., register[8]}; // B[255:0]

// Control and status
start = register[16];  // Start signal
done = register[25];   // Completion flag

// Result (256 bits)
SUM = {register[24], register[23], ..., register[17]}; // SUM[255:0]
```

### 3. Serial Addition Engine

**Algorithm Implementation**:
- **Datapath Width**: 32 bits per cycle
- **Total Width**: 256 bits (8 × 32-bit words)
- **Carry Propagation**: Serial carry chain across words
- **Execution Time**: 8 clock cycles for complete addition

**Addition Process**:
```verilog
for (j = 0; j < 8; j++) begin
    {carry, register[j+17]} <= A[32*j +: 32] + B[32*j +: 32] + carry;
end
```

**State Machine**:
```
IDLE → CALCULATING → IDLE
  ↑         ↓
  ←---------←
```

### 4. AXI Protocol State Machine

**State Definitions**:
```verilog
localparam IDLE          = 0;  // Waiting for transactions
localparam WRITE_CHANNEL = 1;  // Processing write transaction
localparam WRESP_CHANNEL = 2;  // Sending write response
localparam RADDR_CHANNEL = 3;  // Processing read address
localparam RDATA_CHANNEL = 4;  // Sending read data
localparam CALCULATING   = 5;  // Performing addition
```

**Transaction Flow**:

#### Write Transaction
```
IDLE → WRITE_CHANNEL → WRESP_CHANNEL → IDLE
```

#### Read Transaction
```
IDLE → RADDR_CHANNEL → RDATA_CHANNEL → IDLE
```

#### Computation
```
IDLE → CALCULATING → IDLE (when done)
```

## Software Implementation (`main.c`)

### ARM Processor Application

**Key Features**:
- **Memory-Mapped Access**: Direct register manipulation via pointers
- **Random Test Generation**: Automated test vector creation
- **Continuous Testing**: Infinite loop with periodic execution
- **Result Verification**: Real-time output monitoring

**Memory Mapping**:
```c
#define AXI_ADDR0 0x0400000000
volatile unsigned int *AXIAddr0 = (volatile unsigned int *) AXI_ADDR0;
```

**Test Sequence**:
1. **Generate Random Data**: Create 256-bit operands A and B
2. **Write Operands**: Store A and B in hardware registers
3. **Start Computation**: Trigger addition operation
4. **Poll Completion**: Wait for done flag
5. **Read Results**: Retrieve 256-bit sum
6. **Display Output**: Print results via UART
7. **Repeat**: Continuous testing loop

### Test Vector Generation
```c
void generate_random_256bit(uint32_t *array) {
    for (int i = 0; i < 8; i++) {
        array[i] = rand();  // Generate random 32-bit words
    }
}
```

### Hardware Communication Protocol
```c
// Write operands A and B
for(i = 0; i < 8; i++) {
    mem[i] = A[i];      // Write A[i] to register i
    mem[i+8] = B[i];    // Write B[i] to register i+8
}

// Start computation
mem[16] = 1;            // Assert start signal
mem[16] = 0;            // Deassert start signal

// Read results
done_flag = mem[25];    // Check completion
for(i = 0; i < 8; i++) {
    sum[i] = mem[i+17]; // Read result words
}
```

## Performance Characteristics

### Timing Analysis
- **Addition Latency**: 8 clock cycles
- **AXI Overhead**: 2-3 cycles per register access
- **Total Transaction Time**: ~50-100 cycles (depending on bus activity)
- **Throughput**: Limited by software overhead, not hardware

### Resource Utilization (Estimated)
- **LUTs**: ~500-800 (AXI logic + adder)
- **Flip-Flops**: ~1000-1500 (registers + state machines)
- **Block RAM**: 0 (uses distributed memory)
- **DSP Slices**: 8 (for 32-bit additions)

### Comparison with Alternatives
| Implementation | Latency | Area | Throughput |
|----------------|---------|------|------------|
| **Serial (this)** | 8 cycles | Low | Medium |
| **Parallel** | 1 cycle | High | High |
| **Software** | 100+ cycles | None | Low |

## System Integration

### Zynq Platform Requirements
- **Processing System**: ARM Cortex-A9 or A53
- **Programmable Logic**: Sufficient for AXI slave + adder
- **Memory**: DDR for software execution
- **Interconnect**: AXI4-Lite support

### Vivado Block Design Integration
1. **Add Custom IP**: Package AXI slave as IP core
2. **Connect to PS**: Link to ARM processor via AXI interconnect
3. **Address Mapping**: Assign base address (e.g., 0x40000000)
4. **Clock/Reset**: Connect system clock and reset
5. **Generate Bitstream**: Create hardware configuration

### Software Development Environment
- **Xilinx SDK/Vitis**: Cross-compilation toolchain
- **Board Support Package**: Hardware abstraction layer
- **Standard Libraries**: printf, memory access functions
- **Debugging**: JTAG-based debugging support

## Verification and Testing

### Simulation Strategy
1. **AXI Protocol Verification**: Test all transaction types
2. **Functional Testing**: Verify addition correctness
3. **Corner Cases**: Test overflow, zero operands
4. **Timing Analysis**: Verify setup/hold requirements

### Hardware Testing
1. **Known Vectors**: Test with predetermined inputs
2. **Random Testing**: Continuous random verification
3. **Stress Testing**: Maximum frequency operation
4. **Integration Testing**: Full system validation

### Expected Results
```
Input A: 0x11111111_22222222_33333333_44444444_55555555_66666666_77777777_88888888
Input B: 0x12345678_9ABCDEF0_FEDCBA98_76543210_13579BDF_2468ACE0_369CF258_147AD036
Sum:     0x23456789_BCEF1112_31F0EDCB_BABA6654_68ACF134_88CF1346_AAEB49DF_9CF358BE
```

## Applications and Use Cases

### High-Performance Computing
- **Cryptographic Operations**: Large integer arithmetic
- **Digital Signal Processing**: Multi-precision filtering
- **Scientific Computing**: Extended precision calculations
- **Financial Modeling**: High-precision financial calculations

### System-on-Chip Integration
- **Arithmetic Accelerators**: Offload CPU computation
- **Custom Processors**: Specialized arithmetic units
- **Real-Time Systems**: Deterministic computation timing
- **Edge Computing**: Efficient local processing

## Extensions and Enhancements

### Performance Improvements
1. **Pipeline Implementation**: Multi-stage pipeline for higher throughput
2. **Parallel Datapaths**: Multiple 32-bit adders for faster completion
3. **Burst Transfers**: AXI4 burst mode for bulk data transfer
4. **DMA Integration**: Direct memory access for large datasets

### Functional Extensions
1. **Subtraction Support**: Add subtraction capability
2. **Multiplication**: Extend to multiplication operations
3. **Floating Point**: IEEE 754 arithmetic support
4. **Vector Operations**: SIMD-style parallel arithmetic

### Interface Enhancements
1. **AXI4 Full**: Support for burst transfers
2. **AXI-Stream**: Streaming data interface
3. **Interrupt Support**: Completion notification via interrupts
4. **Error Handling**: Enhanced error detection and reporting

## Debugging and Troubleshooting

### Common Issues

#### AXI Protocol Violations
- **Handshaking Errors**: Verify valid/ready signal timing
- **Address Alignment**: Ensure 4-byte aligned addresses
- **Response Codes**: Check RRESP and BRESP values

#### Arithmetic Errors
- **Carry Propagation**: Verify serial carry chain
- **Overflow Handling**: Check for arithmetic overflow
- **Timing Issues**: Verify setup/hold times

#### Software Issues
- **Memory Mapping**: Verify base address configuration
- **Pointer Arithmetic**: Check address calculations
- **Synchronization**: Ensure proper completion polling

### Debug Techniques
1. **ILA Integration**: Use Integrated Logic Analyzer
2. **AXI Protocol Checker**: Vivado AXI verification IP
3. **Software Debugging**: GDB via JTAG
4. **Waveform Analysis**: Detailed signal timing analysis

## File Summary

| File | Description | Purpose |
|------|-------------|---------|
| `axi4_lite_slave.v` | AXI4-Lite slave implementation | Hardware interface |
| `main.c` | ARM processor test application | Software control |

## Learning Objectives

1. **AXI Protocol**: Understanding industry-standard bus protocols
2. **Hardware-Software Co-design**: Integrated system development
3. **Memory-Mapped I/O**: Register-based hardware control
4. **Serial Arithmetic**: Multi-cycle computation techniques
5. **SoC Integration**: Complete system-on-chip design

This project demonstrates professional-grade FPGA development practices and provides a foundation for understanding modern SoC design methodologies used in industry applications.