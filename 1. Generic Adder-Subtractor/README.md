# Generic Adder-Subtractor

This directory contains three different implementations of a configurable N-bit adder-subtractor circuit, demonstrating various Verilog design methodologies and coding styles.

## Overview

The adder-subtractor is a fundamental arithmetic unit that can perform both addition and subtraction operations on N-bit binary numbers. The operation is controlled by a single `Op` signal:
- `Op = 0`: Addition (A + B)
- `Op = 1`: Subtraction (A - B)

The subtraction is implemented using two's complement arithmetic by XORing the B input with the Op signal and using Op as the initial carry-in.

## Implementation Variants

### 1. Continuous Assignment Implementation (`ContinuousAssignment.v`)

**Design Style**: Structural/Dataflow
**Key Features**:
- Uses `assign` statements for combinational logic
- Instantiates full adder modules using continuous assignments
- Clean separation between the main module and full adder implementation
- Demonstrates structural Verilog coding style

**Module**: `ContinuousAssignmentAS`
**Sub-module**: `ContinuousAssignmentFA` (Full Adder)

```verilog
// Key implementation detail
assign BxOp[i] = B[i] ^ Op;
assign s = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (a & cin);
```

### 2. Gate-Level Implementation (`GateLevel.v`)

**Design Style**: Structural/Gate-Level
**Key Features**:
- Uses primitive Verilog gates (`xor`, `and`, `or`, `buf`)
- Lowest level of abstraction
- Explicit gate instantiation for educational purposes
- Demonstrates hardware-level thinking

**Module**: `GateLevelAS`
**Sub-module**: `GateLevelFA` (Full Adder)

```verilog
// Key implementation detail
xor(BxOp[i], B[i], Op);
xor(s, l, cin);
and(m, l, cin);
or(cout, m, n);
```

### 3. Procedural Constructs Implementation (`ProceduralConstructs.v`)

**Design Style**: Behavioral
**Key Features**:
- Uses `always` blocks with procedural assignments
- Employs `for` loops for scalable implementation
- Behavioral modeling approach
- More software-like coding style

**Module**: `ProceduralConstructAS`

```verilog
// Key implementation detail
always @(A, B, Op) begin
    for (i = 1; i < N; i = i + 1) begin
        BxOp[i] = B[i] ^ Op;
        S[i] = A[i] ^ BxOp[i] ^ C[i-1];
        C[i] = (A[i] & BxOp[i]) | (BxOp[i] & C[i-1]) | (A[i] & C[i-1]);
    end
end
```

## Architecture Details

### Common Interface
All implementations share the same module interface:

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `A` | Input | N-bit | First operand |
| `B` | Input | N-bit | Second operand |
| `Op` | Input | 1-bit | Operation select (0=Add, 1=Sub) |
| `S` | Output | N-bit | Result sum/difference |
| `Cout` | Output | 1-bit | Carry out/Borrow |

### Parameter Configuration
- **N**: Configurable bit width (default = 4)
- Supports any bit width from 1 to implementation limits
- All test benches demonstrate different bit widths

### Algorithm Implementation
The adder-subtractor uses the standard approach:
1. **XOR B with Op**: Creates B' = B ⊕ Op
2. **Add A + B' + Op**: Where Op serves as initial carry-in
3. **For Addition**: B' = B, Cin = 0 → A + B
4. **For Subtraction**: B' = ~B, Cin = 1 → A + (~B) + 1 = A - B

## Test Benches

### Test Coverage
The directory includes comprehensive test benches for different bit widths:

#### `TestBench_4bit.v`
- **Target**: 4-bit implementation
- **Test Cases**: 6 comprehensive test vectors
- **Coverage**: Positive/negative numbers, addition/subtraction
- **Duration**: 60ns simulation time

**Test Vectors**:
1. 2 + 1 = 3 (positive addition)
2. -2 + 3 = 1 (mixed sign addition)
3. 7 - 3 = 4 (positive subtraction)
4. -4 - 4 = -8 (negative subtraction)
5. 1 - 3 = -2 (result negative)
6. -1 + (-1) = -2 (negative addition)

#### `TestBench_6bit.v` & `TestBench_8bit.v`
- Extended bit width testing
- Demonstrates scalability of the design
- Larger dynamic range testing

### Running Simulations

To simulate any implementation:

1. **Select Implementation**: Uncomment desired module in testbench
```verilog
// Choose one:
GateLevelAS #(N) uut (
// ContinuousAssignmentAS #(N) uut (
// ProceduralConstructAS #(N) uut (
```

2. **Compile and Run**:
```bash
# Using ModelSim/QuestaSim
vlog *.v
vsim -gui AdderSubtractor_tb
run -all
```

3. **Waveform Analysis**: Observe A, B, Op, S, and Cout signals

## Design Comparison

| Aspect | Continuous Assignment | Gate Level | Procedural |
|--------|----------------------|------------|------------|
| **Abstraction** | Medium | Low | High |
| **Readability** | Good | Fair | Excellent |
| **Synthesis** | Efficient | Efficient | Efficient |
| **Scalability** | Good | Fair | Excellent |
| **Educational Value** | Good | Excellent | Good |
| **Industry Usage** | Common | Rare | Very Common |

## Synthesis Results

All three implementations synthesize to identical or nearly identical hardware:
- **Logic Elements**: N full adders + XOR gates
- **Propagation Delay**: O(N) for ripple carry
- **Area**: Linear with bit width N
- **Power**: Proportional to switching activity

## Key Learning Objectives

1. **Multiple Design Styles**: Understanding different Verilog coding approaches
2. **Parameterized Design**: Creating scalable, reusable modules
3. **Two's Complement Arithmetic**: Hardware implementation of signed arithmetic
4. **Testbench Development**: Comprehensive verification methodology
5. **Design Equivalence**: How different code styles produce equivalent hardware

## Usage Examples

### Instantiation Template
```verilog
// 8-bit adder-subtractor using continuous assignment style
ContinuousAssignmentAS #(.N(8)) my_addsub (
    .A(operand_a),
    .B(operand_b),
    .Op(add_sub_control),
    .S(result),
    .Cout(carry_out)
);
```

### Integration in Larger Systems
- **ALU Component**: Core arithmetic unit in processors
- **DSP Applications**: Basic building block for filters
- **Control Systems**: Feedback and error calculation
- **Memory Controllers**: Address calculation

## Extensions and Modifications

Potential enhancements to explore:
1. **Carry Look-Ahead**: Faster carry propagation
2. **Overflow Detection**: Signed arithmetic overflow flags
3. **Multi-Function ALU**: Add logical operations
4. **Pipeline Stages**: Break into multiple clock cycles
5. **Booth Multiplier Integration**: Combined add/subtract/multiply unit

## Files Summary

| File | Description | Implementation Style |
|------|-------------|---------------------|
| `ContinuousAssignment.v` | Dataflow/structural implementation | assign statements |
| `GateLevel.v` | Gate-level implementation | Primitive gates |
| `ProceduralConstructs.v` | Behavioral implementation | always blocks |
| `TestBench_4bit.v` | 4-bit verification testbench | Comprehensive tests |
| `TestBench_6bit.v` | 6-bit verification testbench | Extended range |
| `TestBench_8bit.v` | 8-bit verification testbench | Maximum range |

This implementation serves as an excellent foundation for understanding digital arithmetic circuits and Verilog design methodologies.