# HDL Implementation of TEA on Xilinx Board

This directory contains a complete hardware implementation of the Tiny Encryption Algorithm (TEA) designed for deployment on Xilinx FPGA development boards, featuring UART communication for remote testing and verification.

## Overview

This project represents a complete system-on-chip implementation that combines the pipelined TEA encryption engine with a comprehensive communication infrastructure. The design enables remote testing of the TEA implementation through serial communication, making it suitable for hardware-in-the-loop verification and real-world deployment scenarios.

### System Architecture

```
PC/Host ←→ UART ←→ SerialRFT ←→ Loop-back Device ←→ TEA Engine
```

**Components**:
1. **TEA Engine**: Pipelined encryption core
2. **Loop-back Device**: Test vector management and protocol handling
3. **SerialRFT**: Top-level integration module
4. **UART**: Serial communication interface

## Implementation Components

### 1. TEA Encryption Engine (`reg8.v`)

**Enhanced Pipelined TEA Implementation**
- **Pipeline Depth**: 32 stages (one per TEA round)
- **Output Control**: Enhanced timing control with output enable counter
- **Reset Handling**: Proper asynchronous reset with synchronous release
- **Pipeline Management**: Controlled output timing after pipeline fill

**Key Enhancements over Basic Pipeline**:
```verilog
reg [7:0] out_en;  // Output enable counter
if (out_en >= CYCLE_NUM) begin
    v0_out <= v0_pipeline_c[CYCLE_NUM - 1];
    v1_out <= v1_pipeline_c[CYCLE_NUM - 1];
end
```

**Module Interface**:
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1-bit | System clock |
| `nrst` | Input | 1-bit | Active-low asynchronous reset |
| `v0_in`, `v1_in` | Input | 32-bit each | Plaintext input |
| `k0`-`k3` | Input | 32-bit each | 128-bit encryption key |
| `v0_out`, `v1_out` | Output | 32-bit each | Ciphertext output |

### 2. UART Communication System (`uart.sv`)

**Professional UART Implementation**
- **Configurable Baud Rate**: Parameterized clock divider
- **Standard Protocol**: 8N1 (8 data bits, no parity, 1 stop bit)
- **Full Duplex**: Independent transmit and receive paths
- **Flow Control**: Ready/valid handshaking

**UART Modules**:

#### `uart_send` - Transmitter
- **Frame Format**: Start bit + 8 data bits + stop bit
- **Edge Detection**: Rising edge triggered transmission
- **Ready Signal**: Indicates availability for new data
- **Baud Rate**: 9600 bps (configurable via DIVIDER parameter)

#### `uart_recv` - Receiver  
- **State Machine**: Robust bit-by-bit reception
- **Start Bit Detection**: Automatic frame synchronization
- **Data Validation**: Stop bit verification
- **Output Control**: Single-cycle ready pulse

#### `baud_clk_gen` - Clock Generator
- **Dual Phase Clocks**: Separate TX and RX timing
- **Phase Alignment**: TX at period start, RX at mid-period
- **Configurable Division**: Parameterized frequency division

**Baud Rate Configuration**:
```verilog
localparam int DIVIDER = 10416;   // 9600 bps from 100MHz
// Alternative: DIVIDER = 868;    // 115200 bps from 100MHz
```

### 3. Loop-back Device (`loop_back_device.v`)

**Test Vector Management System**
- **Protocol Handler**: Manages test sequence execution
- **Data Conversion**: Character-to-bit and bit-to-character conversion
- **State Machine**: Robust test execution control
- **Interface Mapping**: Connects UART to TEA engine

**Key Parameters**:
```verilog
parameter InputSize  = 194; // Total input bits (2 + 64 + 128)
parameter OutputSize = 64;  // Total output bits (64-bit ciphertext)
```

**Input Bit Allocation**:
- **Bits 0-1**: Control signals (clk, nrst)
- **Bits 2-33**: v0_in (32 bits)
- **Bits 34-65**: v1_in (32 bits)  
- **Bits 66-97**: k0 (32 bits)
- **Bits 98-129**: k1 (32 bits)
- **Bits 130-161**: k2 (32 bits)
- **Bits 162-193**: k3 (32 bits)

**Protocol State Machine**:
```
wait_for_data → wait_after_input → send_equal → 
wait_for_output → send_output → wait_after_output → 
send_sharp → wait_for_data
```

**Character Encoding**:
- **'0' (0x30)**: Represents logic 0
- **'1' (0x31)**: Represents logic 1
- **'=' (0x3D)**: Separates input from output
- **'#' (0x23)**: Marks end of transaction

### 4. Serial Remote FPGA Tester (`SerialRFT.sv`)

**Top-Level Integration Module**
- **System Integration**: Connects all components
- **Clock Management**: Single clock domain design
- **Reset Distribution**: Proper reset fanout
- **Signal Routing**: Clean interface connections

**Module Hierarchy**:
```
SerialRFT
├── UART (uart.sv)
├── LBD (loop_back_device.v)
└── CUT (TEA from reg8.v)
```

## Communication Protocol

### Test Execution Sequence

1. **Input Phase**: Host sends 194 characters ('0' or '1')
2. **Processing**: FPGA processes input through TEA engine
3. **Separator**: FPGA sends '=' character
4. **Output Phase**: FPGA sends 64 result characters
5. **Terminator**: FPGA sends '#' character
6. **Repeat**: Ready for next test vector

### Example Transaction
```
Host → FPGA: "00110011...01010101" (194 chars)
FPGA → Host: "00110011...01010101" (echo input)
FPGA → Host: "="
FPGA → Host: "11001100...10101010" (64 chars output)
FPGA → Host: "#"
```

## Hardware Requirements

### FPGA Resources (Estimated)
- **LUTs**: ~3000-4000
- **Flip-Flops**: ~6500-7000  
- **Block RAM**: 0 (uses distributed RAM)
- **DSP Slices**: ~200 (for TEA arithmetic)
- **I/O Pins**: 4 minimum (clk, rst, rx, tx)

### Xilinx Board Compatibility
- **Artix-7 Series**: Basys 3, Nexys 4 DDR
- **Zynq-7000 Series**: Zybo, ZedBoard, Pynq-Z1
- **Kintex-7 Series**: KC705, Genesys 2
- **Any board with**: UART interface, 100MHz clock

## Deployment Instructions

### 1. Hardware Setup
```verilog
// Pin assignments (example for Basys 3)
set_property PACKAGE_PIN W5 [get_ports clk]     // 100MHz clock
set_property PACKAGE_PIN U18 [get_ports rst]    // Reset button
set_property PACKAGE_PIN B18 [get_ports rx]     // UART RX
set_property PACKAGE_PIN A18 [get_ports tx]     // UART TX
```

### 2. Vivado Project Setup
1. **Create New Project**: RTL project targeting your board
2. **Add Sources**: Include all .v and .sv files
3. **Set Top Module**: `SerialRFT`
4. **Add Constraints**: Pin assignments and timing constraints
5. **Synthesize**: Run synthesis and implementation
6. **Generate Bitstream**: Create programming file

### 3. Host Communication Setup
```python
# Python example for host communication
import serial
import time

ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=1)

# Send test vector (194 bits as characters)
test_input = "00" + "01234567" * 24 + "10"  # Example pattern
ser.write(test_input.encode())

# Read response
response = ser.read(194 + 1 + 64 + 1)  # Echo + '=' + output + '#'
print(f"Response: {response.decode()}")
```

## Verification and Testing

### Test Vector Generation
```python
def generate_tea_test(v0, v1, k0, k1, k2, k3):
    """Generate test vector string for TEA encryption"""
    # Convert to binary strings
    clk_nrst = "00"  # Clock low, reset active
    v0_bits = format(v0, '032b')
    v1_bits = format(v1, '032b')
    k0_bits = format(k0, '032b')
    k1_bits = format(k1, '032b')
    k2_bits = format(k2, '032b')
    k3_bits = format(k3, '032b')
    
    return clk_nrst + v0_bits + v1_bits + k0_bits + k1_bits + k2_bits + k3_bits
```

### Expected Results Verification
Use the C reference implementation from the previous TEA project to generate expected ciphertext for comparison.

### Performance Testing
- **Throughput**: Measure encryptions per second
- **Latency**: Time from input to output
- **Resource Utilization**: Post-implementation reports
- **Timing Closure**: Verify timing constraints met

## Applications and Use Cases

### Educational Applications
- **Digital Design Lab**: Complete system design example
- **FPGA Training**: Real hardware deployment experience
- **Protocol Development**: UART communication learning
- **Verification Methods**: Hardware-software co-verification

### Industrial Applications
- **Cryptographic Accelerators**: High-speed encryption engines
- **Secure Communications**: Embedded encryption systems
- **IoT Security**: Lightweight device encryption
- **Hardware Security Modules**: Dedicated crypto processors

## Troubleshooting

### Common Issues

#### UART Communication Problems
- **Baud Rate Mismatch**: Verify DIVIDER parameter calculation
- **Pin Assignments**: Check constraint file accuracy
- **Flow Control**: Ensure proper ready/valid handshaking

#### TEA Engine Issues
- **Pipeline Timing**: Verify output enable counter operation
- **Reset Behavior**: Check asynchronous reset implementation
- **Data Corruption**: Validate input bit mapping

#### Integration Problems
- **Clock Domains**: Ensure single clock throughout system
- **Signal Routing**: Verify module interconnections
- **Resource Conflicts**: Check for synthesis warnings

### Debug Techniques
1. **Simulation First**: Verify in ModelSim before hardware
2. **Incremental Testing**: Test UART separately, then integrate
3. **Logic Analyzer**: Use ILA cores for internal signal monitoring
4. **Known Vectors**: Test with verified input/output pairs

## Extensions and Enhancements

### Performance Improvements
1. **Higher Baud Rates**: Increase UART speed for faster testing
2. **Parallel Processing**: Multiple TEA engines for higher throughput
3. **DMA Integration**: Direct memory access for bulk operations
4. **AXI Interface**: Standard bus interface integration

### Security Enhancements
1. **Key Management**: Secure key storage and rotation
2. **Side-Channel Protection**: Power analysis countermeasures
3. **Authentication**: Message authentication codes
4. **Random Number Generation**: Hardware entropy sources

### System Integration
1. **Ethernet Interface**: Network-based testing
2. **USB Communication**: Higher-speed host interface
3. **Memory Interface**: External memory for large datasets
4. **Multi-Algorithm Support**: TEA variants and other ciphers

## File Summary

| File | Description | Purpose |
|------|-------------|---------|
| `uart.sv` | Complete UART implementation | Serial communication |
| `SerialRFT.sv` | Top-level integration module | System assembly |
| `loop_back_device.v` | Test protocol handler | Test vector management |
| `reg8.v` | Enhanced TEA implementation | Encryption engine |

## Learning Objectives

1. **System Integration**: Complete FPGA system design
2. **Communication Protocols**: UART implementation and usage
3. **Hardware-Software Interface**: Host-FPGA communication
4. **Real Hardware Deployment**: FPGA programming and testing
5. **Verification Methodology**: Hardware-in-the-loop testing

This implementation demonstrates a complete path from algorithm to deployed hardware, providing valuable experience in real-world FPGA development and system integration.