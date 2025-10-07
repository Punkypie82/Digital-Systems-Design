# Pipelined TEA Implementation

This directory contains a high-performance pipelined hardware implementation of the Tiny Encryption Algorithm (TEA), designed to achieve maximum throughput for cryptographic operations on FPGA platforms.

## Overview

The Tiny Encryption Algorithm (TEA) is a block cipher designed for simplicity and efficiency. This implementation transforms the iterative TEA algorithm into a fully pipelined architecture, allowing continuous encryption operations with one result per clock cycle after initial pipeline fill.

### TEA Algorithm Background
- **Block Size**: 64 bits (two 32-bit words)
- **Key Size**: 128 bits (four 32-bit words)
- **Rounds**: 32 iterations
- **Operations**: Addition, XOR, bit shifting
- **Design Goals**: Simplicity, speed, small code/hardware footprint

## Algorithm Details

### TEA Encryption Process
The TEA algorithm operates on two 32-bit data words (v0, v1) using a 128-bit key (k0, k1, k2, k3):

```c
// Pseudo-code for one TEA round
sum += delta;
v0 += ((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1);
v1 += ((v0 << 4) + k2) ^ (v0 + sum) ^ ((v0 >> 5) + k3);
```

**Key Constants**:
- **Delta**: `0x9E3779B9` (derived from golden ratio)
- **Rounds**: 32 iterations
- **Sum**: Accumulates delta each round

## Implementation Architecture

### Pipeline Design Philosophy
The implementation transforms the sequential 32-round TEA algorithm into a 32-stage pipeline where:
- Each stage performs one TEA round
- Multiple encryptions can be processed simultaneously
- Throughput of one encryption per clock cycle (after initial latency)

### Two Implementation Variants

The file contains two TEA module implementations:

#### 1. Basic Pipelined TEA (Lines 1-74)
- **Immediate Output**: Results available every cycle
- **Continuous Operation**: No built-in flow control
- **Simple Interface**: Direct input/output mapping

#### 2. Enhanced Pipelined TEA (Lines 78-158)
- **Counter Control**: Built-in pipeline fill detection
- **Controlled Output**: Results only after pipeline is full
- **Enhanced Timing**: More precise output control

### Module Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1-bit | Clock signal |
| `nrst` | Input | 1-bit | Active-low reset |
| `v0_in`, `v1_in` | Input | 32-bit each | Plaintext input words |
| `k0`, `k1`, `k2`, `k3` | Input | 32-bit each | 128-bit encryption key |
| `v0_out`, `v1_out` | Output | 32-bit each | Ciphertext output words |

## Pipeline Architecture Details

### Pipeline Registers
```verilog
reg [31:0]  v0_pipeline_p  [0:CYCLE_NUM-1];  // v0 data pipeline
reg [31:0]  v1_pipeline_p  [0:CYCLE_NUM-1];  // v1 data pipeline  
reg [31:0]  sum_pipeline   [0:CYCLE_NUM-1];  // Sum accumulation pipeline
reg [127:0] key_pipeline   [0:CYCLE_NUM-1];  // Key propagation pipeline
```

### Pipeline Stage (`singleTeaStage`)
Each pipeline stage implements one TEA round:

```verilog
module singleTeaStage (
    input [31:0] v0_p, v1_p, sum,
    input [31:0] k0, k1, k2, k3,
    output reg [31:0] v0_c, v1_c
);
    reg [31:0] temp_v0;
    always @(v0_p, v1_p, sum, k0, k1, k2, k3) begin
        temp_v0 = v0_p + (((v1_p << 4) + k0) ^ (v1_p + sum) ^ ((v1_p >> 5) + k1));
        v1_c = v1_p + (((temp_v0 << 4) + k2) ^ (temp_v0 + sum) ^ ((temp_v0 >> 5) + k3));
        v0_c = temp_v0;
    end
endmodule
```

### Pipeline Flow
```
Stage 0:  Round 1  (sum = 1×delta)
Stage 1:  Round 2  (sum = 2×delta)
Stage 2:  Round 3  (sum = 3×delta)
...
Stage 31: Round 32 (sum = 32×delta)
```

**Data Flow**:
1. **Input Stage**: Load plaintext and key
2. **Processing Stages**: 32 TEA rounds in parallel
3. **Output Stage**: Ciphertext available

## Performance Characteristics

### Timing Analysis
- **Pipeline Depth**: 32 stages
- **Initial Latency**: 32 clock cycles
- **Steady-State Throughput**: 1 encryption per cycle
- **Critical Path**: Single TEA round computation

### Throughput Comparison
| Implementation | Latency | Throughput | Encryptions/sec @ 100MHz |
|----------------|---------|------------|---------------------------|
| **Sequential** | 32 cycles | 1/32 cycles | 3.125M |
| **Pipelined** | 32 cycles | 1 cycle | 100M |
| **Speedup** | 1× | **32×** | **32×** |

### Resource Utilization (Estimated)
- **Pipeline Registers**: 32 × (2×32 + 32 + 128) = 6,144 bits
- **Combinational Logic**: 32 × (TEA round logic)
- **DSP Slices**: 32 × 6 = 192 multipliers (for shifts/adds)
- **LUTs**: ~2000-3000 (depending on optimization)

## Reference Implementation

### C Reference (`TEA.c`)
The directory includes a C reference implementation for verification:
- **Software TEA**: Standard iterative implementation
- **Test Vectors**: Multiple plaintext/key combinations
- **Expected Results**: Known ciphertext for verification
- **Debugging Aid**: Step-by-step computation visibility

**Key Test Cases from C Reference**:
1. **Test Case 1**: `v0=0x11223344, v1=0x55667788`
2. **Test Case 2**: `v0=0xdeadbeef, v1=0xfeedface`

## Verification Environment

### Test Bench (`TestBench.v`)
**Configuration**: Single test vector with comprehensive monitoring
**Test Vector**:
```verilog
v0_in = 32'h01234567;  // Plaintext word 0
v1_in = 32'h89abcdef;  // Plaintext word 1
k0 = 32'h00112233;     // Key word 0
k1 = 32'h44556677;     // Key word 1  
k2 = 32'h8899aabb;     // Key word 2
k3 = 32'hccddeeff;     // Key word 3
```

**Additional Test Vectors**: Multiple commented test cases for extended verification

### Simulation Environment

#### `run.do` - ModelSim/QuestaSim Automation
```tcl
vlog -reportprogress 300 -work work Path/to/pipelineTea.v
vlog -reportprogress 300 -work work Path/to/TestBench.v
vsim -gui work.TEA_tb -voptargs=+acc
do wave.do
run 830ns
```

#### `wave.do` - Waveform Configuration
**Signal Groups**:
- **Input Signals**: clk, nrst, v0_in, v1_in, k0-k3
- **Output Signals**: v0_out, v1_out
- **Pipeline Internals**: Pipeline register arrays
- **Control Signals**: Counter (enhanced version)

## Security Considerations

### Cryptographic Properties
- **Key Schedule**: Static key propagation through pipeline
- **Round Function**: Maintains TEA's cryptographic properties
- **Avalanche Effect**: Small input changes cause large output changes
- **Diffusion**: Each output bit depends on all input bits

### Side-Channel Considerations
- **Timing Attacks**: Constant-time operation (pipeline)
- **Power Analysis**: Uniform power consumption per cycle
- **Electromagnetic**: Consider register switching patterns
- **Fault Injection**: Pipeline state corruption risks

## Applications and Use Cases

### High-Throughput Encryption
- **Network Security**: IPSec, VPN acceleration
- **Storage Encryption**: High-speed disk encryption
- **Streaming Media**: Real-time content protection
- **IoT Security**: Lightweight device encryption

### System Integration
- **FPGA Accelerators**: Cryptographic co-processors
- **SoC Integration**: ARM+FPGA hybrid systems
- **Network Processors**: Inline encryption engines
- **Hardware Security Modules**: Dedicated crypto hardware

## Running Simulations

### Prerequisites
- ModelSim/QuestaSim simulator
- Verilog compilation support
- TEA.c reference for result verification

### Simulation Steps

1. **Navigate to Directory**:
```bash
cd "4. Pipelined TEA Implementation"
```

2. **Compile C Reference** (optional):
```bash
gcc -o tea TEA.c
./tea  # Generate expected results
```

3. **Run HDL Simulation**:
```bash
vsim -do run.do
```

4. **Manual Simulation**:
```bash
vlog pipelineTea.v TestBench.v
vsim -gui TEA_tb
do wave.do
run -all
```

### Verification Process
1. **Compare Results**: HDL output vs. C reference
2. **Pipeline Timing**: Verify 32-cycle latency
3. **Throughput**: Confirm continuous operation
4. **Reset Behavior**: Validate pipeline clearing

## Extensions and Enhancements

### Performance Optimizations
1. **Parallel Pipelines**: Multiple encryption engines
2. **Key Scheduling**: Dynamic key generation
3. **Block Chaining**: CBC, CTR mode support
4. **Compression**: Integrated compression/encryption

### Security Enhancements
1. **Key Whitening**: Additional key mixing
2. **Round Randomization**: Variable round counts
3. **Masking**: Side-channel attack protection
4. **Authentication**: Integrated MAC computation

### Advanced Features
1. **Decrypt Pipeline**: Parallel decryption capability
2. **Multi-Algorithm**: TEA/XTEA/XXTEA support
3. **Key Management**: Secure key storage/rotation
4. **Error Detection**: Parity/ECC protection

## Design Verification Strategy

### Functional Verification
1. **Algorithm Correctness**: Match C reference results
2. **Pipeline Behavior**: Verify stage-by-stage operation
3. **Boundary Conditions**: Test edge cases
4. **Stress Testing**: Continuous operation validation

### Timing Verification
1. **Setup/Hold**: Verify timing constraints
2. **Clock Skew**: Multi-clock domain analysis
3. **Pipeline Hazards**: Data dependency checking
4. **Maximum Frequency**: Performance characterization

## File Summary

| File | Description | Purpose |
|------|-------------|---------|
| `pipelineTea.v` | Pipelined TEA implementation | Main HDL design |
| `TEA.c` | C reference implementation | Verification reference |
| `TestBench.v` | Verilog testbench | HDL verification |
| `run.do` | ModelSim automation script | Simulation setup |
| `wave.do` | Waveform configuration | Signal analysis |

## Learning Objectives

1. **Cryptographic Hardware**: Understanding crypto algorithm implementation
2. **Pipeline Design**: Advanced pipeline architecture concepts
3. **Performance Optimization**: Throughput vs. area trade-offs
4. **Verification Methodology**: Hardware/software co-verification
5. **Security Considerations**: Hardware security implications

This pipelined TEA implementation demonstrates how cryptographic algorithms can be transformed from sequential software into high-performance parallel hardware, providing significant performance improvements for encryption-intensive applications.