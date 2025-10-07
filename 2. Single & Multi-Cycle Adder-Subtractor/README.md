# Single & Multi-Cycle Adder-Subtractor

This directory contains two different timing implementations of an N-bit adder-subtractor, demonstrating single-cycle and multi-cycle design approaches for digital arithmetic units.

## Overview

This project explores the trade-offs between computational speed and hardware complexity by implementing the same arithmetic functionality using two different timing strategies:

1. **Single-Cycle Implementation**: Completes operation in one clock cycle
2. **Multi-Cycle Implementation**: Distributes operation across multiple clock cycles

Both implementations provide identical functionality but with different performance characteristics and resource utilization patterns.

## Implementation Variants

### 1. Single-Cycle Implementation (`oneCycle.v`)

**Design Philosophy**: Complete operation in one clock cycle
**Key Features**:
- Instantiates a combinational adder-subtractor core
- Registers inputs and outputs on clock edges
- Provides immediate result availability
- Higher combinational logic complexity

**Architecture**:
```
Input Registers → Combinational Logic → Output Registers
     (1 cycle)         (0 cycles)          (1 cycle)
```

**Module**: `AdderSubtractor` with `AdderSubtractorComb`

**Interface**:
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `A`, `B` | Input | N-bit | Operands |
| `rst` | Input | 1-bit | Reset signal |
| `addsub` | Input | 1-bit | Operation (0=Add, 1=Sub) |
| `start` | Input | 1-bit | Start computation |
| `clk` | Input | 1-bit | Clock signal |
| `sum` | Output | N-bit | Result |
| `cout` | Output | 1-bit | Carry out |
| `done` | Output | 1-bit | Completion flag |

**Timing Characteristics**:
- **Latency**: 1 clock cycle
- **Throughput**: 1 operation per cycle (after initial latency)
- **Critical Path**: Full N-bit ripple carry chain

### 2. Multi-Cycle Implementation (`nCycle.v`)

**Design Philosophy**: Distribute computation across N clock cycles
**Key Features**:
- Processes one bit position per clock cycle
- Reduced combinational logic complexity
- Lower maximum operating frequency requirements
- Sequential state machine control

**Architecture**:
```
Cycle 0: Load inputs, initialize
Cycle 1: Process bit 0
Cycle 2: Process bit 1
...
Cycle N: Process bit N-1, output result
```

**Module**: `AdderSubtractor` (multi-cycle version)

**Additional Interface Signals**:
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `calculating` | Output | 1-bit | Computation in progress |

**Internal State**:
- `regA`, `regB`: Input operand registers
- `regOp`: Operation register
- `partialSum`: Accumulating result
- `carry`: Carry chain register
- `i`: Bit position counter (3-bit for up to 8-bit operations)

**Timing Characteristics**:
- **Latency**: N+1 clock cycles
- **Throughput**: 1 operation per (N+1) cycles
- **Critical Path**: Single bit addition logic

## Design Comparison

| Aspect | Single-Cycle | Multi-Cycle |
|--------|--------------|-------------|
| **Latency** | 1 cycle | N+1 cycles |
| **Throughput** | High | Low |
| **Logic Complexity** | High | Low |
| **Critical Path** | Long (N-bit) | Short (1-bit) |
| **Max Frequency** | Lower | Higher |
| **Area** | Larger | Smaller |
| **Power** | Higher peak | Lower average |
| **Pipeline Friendly** | Yes | No |

## State Machine (Multi-Cycle)

The multi-cycle implementation uses a simple state machine:

```
IDLE → CALCULATING → DONE → IDLE
```

**State Transitions**:
1. **IDLE**: Wait for `start` signal
2. **CALCULATING**: Process bits sequentially (i = 0 to N-1)
3. **DONE**: Assert `done` signal, output results
4. **Return to IDLE**: Ready for next operation

## Test Environment

### Test Bench (`TestBench_6bit.v`)

**Configuration**: 6-bit operands for comprehensive testing
**Test Coverage**: 10 test vectors covering:
- Positive number addition
- Negative number addition (two's complement)
- Mixed sign operations
- Subtraction operations
- Edge cases (overflow conditions)

**Test Vectors**:
1. 1 + 1 = 2 (basic addition)
2. -29 + 26 = -3 (mixed signs)
3. 22 - 9 = 13 (positive subtraction)
4. -1 + 1 = 0 (zero result)
5. 27 - 21 = 6 (positive result)
6. -19 + (-26) = -45 (negative addition)
7. 6 - 1 = 5 (simple subtraction)
8. -31 - 9 = -40 (negative subtraction)
9. -21 + 25 = 4 (mixed to positive)
10. 23 - 7 = 16 (final test)

### Simulation Scripts

#### `run.do` - ModelSim/QuestaSim Automation
```tcl
vlog -reportprogress 300 -work work Path/to/nCycle.v
vlog -reportprogress 300 -work work Path/to/TestBench_6bit.v
vsim -gui work.AdderSubtractor_tb -voptargs=+acc
do wave.do
run 830ns
```

#### `wave.do` - Waveform Configuration
- **Testbench Signals**: A, B, rst, addsub, start, clk, sum, cout, done, calculating
- **Internal Signals**: regA, regB, i (bit counter)
- **Organized Groups**: Testbench and AdderSubtractor internal signals
- **Time Window**: 0-105ns initial view

## Running Simulations

### Prerequisites
- ModelSim/QuestaSim simulator
- Verilog compilation support

### Simulation Steps

1. **Navigate to Directory**:
```bash
cd "2. Single & Multi-Cycle Adder-Subtractor"
```

2. **Run Automated Simulation**:
```bash
# For ModelSim/QuestaSim
vsim -do run.do
```

3. **Manual Compilation** (alternative):
```bash
# Compile sources
vlog oneCycle.v TestBench_6bit.v    # For single-cycle
# OR
vlog nCycle.v TestBench_6bit.v      # For multi-cycle

# Start simulation
vsim -gui AdderSubtractor_tb
do wave.do
run -all
```

### Waveform Analysis

**Key Observations**:
- **Single-Cycle**: `done` asserts immediately after `start`
- **Multi-Cycle**: `calculating` shows computation progress, `done` asserts after N+1 cycles
- **Carry Propagation**: Visible in multi-cycle internal registers
- **Timing Relationships**: Clock edge alignment and setup/hold times

## Performance Analysis

### Timing Metrics (6-bit Example)

| Implementation | Latency | Throughput | Cycles per Operation |
|----------------|---------|------------|---------------------|
| Single-Cycle | 10ns | 100 MOPS @ 100MHz | 1 |
| Multi-Cycle | 70ns | ~14.3 MOPS @ 100MHz | 7 |

### Resource Utilization (Estimated)

| Resource | Single-Cycle | Multi-Cycle | Ratio |
|----------|--------------|-------------|-------|
| **LUTs** | 6N + overhead | N + overhead | ~6:1 |
| **Registers** | 2N + control | 4N + control | ~1:2 |
| **Critical Path** | N-bit ripple | 1-bit add | ~N:1 |

## Use Cases and Applications

### Single-Cycle Advantages
- **High-Performance Processors**: Where throughput is critical
- **Pipeline Stages**: As arithmetic execution units
- **DSP Applications**: High-speed signal processing
- **Parallel Processing**: Multiple independent operations

### Multi-Cycle Advantages
- **Low-Power Applications**: Reduced peak power consumption
- **Area-Constrained Designs**: Minimal logic footprint
- **Educational Purposes**: Clear visualization of arithmetic process
- **Legacy System Integration**: Lower frequency requirements

## Extensions and Enhancements

### Possible Improvements
1. **Carry Look-Ahead**: Reduce single-cycle critical path
2. **Pipeline Multi-Cycle**: Overlap operations for better throughput
3. **Configurable Cycles**: Runtime selection of cycle count
4. **Error Detection**: Parity or checksum validation
5. **Floating Point**: Extend to IEEE 754 arithmetic

### Advanced Implementations
- **Booth Multiplier Integration**: Combined add/subtract/multiply
- **SIMD Operations**: Parallel narrow-width operations
- **Approximate Computing**: Reduced precision for energy savings

## File Summary

| File | Description | Target Implementation |
|------|-------------|----------------------|
| `oneCycle.v` | Single-cycle adder-subtractor | Fast, high-throughput |
| `nCycle.v` | Multi-cycle adder-subtractor | Low-area, low-power |
| `TestBench_6bit.v` | 6-bit verification testbench | Both implementations |
| `TestBench_one.v` | Single-cycle specific tests | Single-cycle only |
| `TestBench_multi.v` | Multi-cycle specific tests | Multi-cycle only |
| `run.do` | ModelSim automation script | Simulation setup |
| `wave.do` | Waveform viewer configuration | Signal analysis |

## Learning Objectives

1. **Design Trade-offs**: Understanding latency vs. area trade-offs
2. **Timing Analysis**: Clock cycle budgeting and critical path analysis
3. **State Machine Design**: Sequential control logic implementation
4. **Verification Methodology**: Comprehensive testbench development
5. **Simulation Tools**: Professional EDA tool usage

This project provides excellent insight into fundamental digital design decisions and their implications for system performance and resource utilization.