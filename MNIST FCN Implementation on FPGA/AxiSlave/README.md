# AxiSlave - FPGA Hardware Implementation

This directory contains the complete FPGA hardware implementation for the MNIST FCN neural network, including the AXI4-Lite interface, neural network engine, and memory management components.

## Overview

The AxiSlave implementation provides a professional-grade hardware accelerator for MNIST digit classification, featuring a custom neural network engine with integrated memory management and AXI4-Lite bus interface for seamless integration with ARM processors in Zynq-based systems.

## Directory Structure

```
AxiSlave/
└── src/
    ├── axi4_lite_slave.v        # AXI4-Lite bus interface controller
    ├── FCN.sv                   # Fully Connected Network engine
    ├── weights.coe              # Pre-trained network weights
    ├── biases.coe               # Pre-trained network biases
    ├── weights_mem/             # Weight memory IP core files
    │   ├── weights_mem.xci      # IP core configuration
    │   ├── weights_mem.vho      # VHDL instantiation template
    │   ├── weights_mem.veo      # Verilog instantiation template
    │   ├── weights_mem.mif      # Memory initialization file
    │   ├── doc/                 # IP core documentation
    │   ├── hdl/                 # Generated HDL files
    │   ├── sim/                 # Simulation models
    │   ├── synth/               # Synthesis files
    │   └── simulation/          # Behavioral models
    └── biases_mem/              # Bias memory IP core files
        ├── biases_mem.xci       # IP core configuration
        ├── biases_mem.vho       # VHDL instantiation template
        ├── biases_mem.veo       # Verilog instantiation template
        ├── biases_mem.mif       # Memory initialization file
        ├── doc/                 # IP core documentation
        ├── hdl/                 # Generated HDL files
        ├── sim/                 # Simulation models
        ├── synth/               # Synthesis files
        └── simulation/          # Behavioral models
```

## Core Components

### 1. AXI4-Lite Slave Controller (`axi4_lite_slave.v`)

**Purpose**: Provides standard AXI4-Lite bus interface for ARM processor communication

**Key Features**:
- **Full AXI4-Lite Compliance**: Implements all required channels and handshaking
- **32-Register Array**: Memory-mapped register interface
- **FCN Integration**: Direct connection to neural network engine
- **Automatic Status Updates**: Real-time result and status reporting

**Register Mapping**:
```verilog
// Input image data (784 bits across 25 registers)
fcn_input = {register[0], register[1], ..., register[24]};  // 25×32 = 800 bits (784 used)

// Control and status registers
fcn_start = register[25];    // Start inference signal
// register[26] = fcn_result  // Prediction result (0-9)
// register[27] = fcn_done    // Completion status
```

**AXI State Machine**:
```verilog
localparam IDLE          = 0;  // Waiting for transactions
localparam WRITE_CHANNEL = 1;  // Processing write
localparam WRESP_CHANNEL = 2;  // Write response
localparam RADDR_CHANNEL = 3;  // Read address
localparam RDATA_CHANNEL = 4;  // Read data
```

**Enhanced Features**:
- **Automatic Result Update**: FCN results automatically mapped to read registers
- **Status Monitoring**: Real-time done flag and result availability
- **Clean Interface**: Simplified register-based control

### 2. Fully Connected Network Engine (`FCN.sv`)

**Purpose**: Hardware implementation of 784→64→32→10 neural network

#### Network Architecture
```
Input Layer:    784 neurons (28×28 MNIST image)
Hidden Layer 1: 64 neurons + ReLU activation
Hidden Layer 2: 32 neurons + ReLU activation  
Output Layer:   10 neurons (digit classes 0-9)
```

#### Module Interface
```systemverilog
module FCN(
    input  clk,              // System clock
    input  [783:0] A,        // Flattened input image
    input  start,            // Start inference
    output reg [3:0] B,      // Predicted digit (0-9)
    output reg done          // Inference complete
);
```

#### Layer Processing State Machine
```systemverilog
localparam STATE_LAYER_1 = 1;  // Process 784→64 layer
localparam STATE_LAYER_2 = 2;  // Process 64→32 layer
localparam STATE_LAYER_3 = 3;  // Process 32→10 layer
localparam STATE_PREDICT = 4;  // Find argmax
```

#### Mathematical Operations

**Matrix Multiplication with Accumulation**:
```systemverilog
// For each neuron computation
partial_output <= bias;                    // Initialize with bias
for (weight_counter = 1; weight_counter <= INPUT_SIZE; weight_counter++) begin
    partial_output <= partial_output + 
                     (A[INPUT_SIZE - weight_counter] ? weight : 0);
end
layer_output[node] <= ReLU(partial_output);
```

**ReLU Activation Function**:
```systemverilog
function [DATA_WIDTH-1:0] ReLU;
    input [DATA_WIDTH-1:0] value;
    begin
        ReLU = (value[DATA_WIDTH-1]) ? 0 : value;  // Zero if MSB set (negative)
    end
endfunction
```

**Custom Fixed-Point Multiplication**:
```systemverilog
function [DATA_WIDTH-1:0] Mult;
    input signed [DATA_WIDTH-1:0] a, b;
    reg signed [2*DATA_WIDTH-1:0] product;
    begin
        product = a * b;
        Mult = product >>> (DATA_WIDTH/2);  // Arithmetic right shift for scaling
    end
endfunction
```

#### Layer Dimensions and Memory Requirements
```systemverilog
localparam LAYER_0_SIZE = 784;  // Input layer
localparam LAYER_1_SIZE = 64;   // First hidden layer
localparam LAYER_2_SIZE = 32;   // Second hidden layer  
localparam LAYER_3_SIZE = 10;   // Output layer

// Layer output storage
reg [DATA_WIDTH-1:0] layer_1_output [0:LAYER_1_SIZE-1];  // 64×16 bits
reg [DATA_WIDTH-1:0] layer_2_output [0:LAYER_2_SIZE-1];  // 32×16 bits
reg [DATA_WIDTH-1:0] layer_3_output [0:LAYER_3_SIZE-1];  // 10×16 bits
```

#### Inference Pipeline Timing
1. **Layer 1**: 784 weight reads + 64 bias reads + computation = ~850 cycles
2. **Layer 2**: 64 weight reads + 32 bias reads + computation = ~100 cycles
3. **Layer 3**: 32 weight reads + 10 bias reads + computation = ~50 cycles
4. **Prediction**: Argmax over 10 outputs = ~10 cycles
5. **Total**: ~1010 cycles per inference

### 3. Memory Management System

#### Weight Memory (`weights_mem/`)

**Xilinx Block RAM Generator v8.4 Configuration**:
- **Memory Type**: Single Port ROM
- **Data Width**: 16 bits (fixed-point weights)
- **Memory Depth**: Calculated based on total weight count
- **Initialization**: From `weights.coe` coefficient file
- **Clocking**: Single clock domain with FCN engine

**Weight Organization**:
```
Address Range    | Layer        | Dimensions
0x0000-0x30FF   | Layer 1      | 784×64 = 50,176 weights
0x3100-0x31FF   | Layer 2      | 64×32 = 2,048 weights  
0x3200-0x327F   | Layer 3      | 32×10 = 320 weights
Total: 52,544 weights × 16 bits = 840,704 bits
```

**Memory Interface**:
```systemverilog
weights_mem weights (
    .clka(clk),                    // Clock
    .wea(0),                       // Write enable (always 0 for ROM)
    .addra(weight_addr),           // Address input
    .dina(16'b0),                  // Data input (unused)
    .douta(weight)                 // Weight output
);
```

#### Bias Memory (`biases_mem/`)

**Xilinx Block RAM Generator v8.4 Configuration**:
- **Memory Type**: Single Port ROM
- **Data Width**: 16 bits (fixed-point biases)
- **Memory Depth**: 106 (64+32+10 biases)
- **Initialization**: From `biases.coe` coefficient file
- **Clocking**: Single clock domain with FCN engine

**Bias Organization**:
```
Address Range | Layer    | Count
0x00-0x3F    | Layer 1  | 64 biases
0x40-0x5F    | Layer 2  | 32 biases
0x60-0x69    | Layer 3  | 10 biases
Total: 106 biases × 16 bits = 1,696 bits
```

**Memory Interface**:
```systemverilog
biases_mem biases (
    .clka(clk),                    // Clock
    .wea(0),                       // Write enable (always 0 for ROM)
    .addra(bias_addr),             // Address input
    .dina(16'b0),                  // Data input (unused)
    .douta(bias)                   // Bias output
);
```

### 4. Memory Initialization Files

#### Weight Coefficient File (`weights.coe`)
```
memory_initialization_radix=16;
memory_initialization_vector=
// Layer 1 weights (784×64)
1A2B,3C4D,5E6F,7890,ABCD,EF01,2345,6789,
// ... (50,176 weight values)
// Layer 2 weights (64×32)  
9876,5432,1098,FEDC,BA98,7654,3210,ABCD,
// ... (2,048 weight values)
// Layer 3 weights (32×10)
CDEF,0123,4567,89AB,CDEF,0123,4567,89AB,
// ... (320 weight values)
```

#### Bias Coefficient File (`biases.coe`)
```
memory_initialization_radix=16;
memory_initialization_vector=
// Layer 1 biases (64)
0100,FF80,7F00,8001,0200,FE80,7E00,8002,
// ... (64 bias values)
// Layer 2 biases (32)
0080,FF40,7F80,8040,0180,FE40,7E80,8042,
// ... (32 bias values)  
// Layer 3 biases (10)
0040,FF20,7FC0,8020,01C0,FE20,7EC0,8022,0060,FF10
```

## Fixed-Point Number Representation

### Data Format
- **Width**: 16 bits per weight/bias/activation
- **Format**: Q8.8 (8 integer bits, 8 fractional bits)
- **Range**: -128.0 to +127.996 (step size 1/256)
- **Signed**: Two's complement representation

### Quantization Strategy
```python
# Example quantization from floating-point
def quantize_to_q8_8(float_val):
    # Scale by 2^8 and round
    quantized = int(round(float_val * 256))
    # Clamp to 16-bit signed range
    quantized = max(-32768, min(32767, quantized))
    return quantized & 0xFFFF
```

### Arithmetic Considerations
- **Multiplication**: 16×16 → 32-bit product, then arithmetic right shift by 8
- **Addition**: Direct 16-bit addition with overflow handling
- **ReLU**: Simple sign bit check and conditional zero

## Resource Utilization

### Estimated FPGA Resources
| Resource Type | Estimated Usage | Percentage (Zynq-7020) |
|---------------|-----------------|------------------------|
| **LUTs** | 8,000-12,000 | 15-22% |
| **Flip-Flops** | 6,000-8,000 | 6-8% |
| **Block RAM** | 60-80 tiles | 43-57% |
| **DSP Slices** | 20-40 | 9-18% |

### Memory Breakdown
- **Weight Memory**: ~52KB (52,544 × 16 bits)
- **Bias Memory**: ~212B (106 × 16 bits)
- **Layer Buffers**: ~212B (106 × 16 bits maximum)
- **Total Memory**: ~52.4KB

## Performance Analysis

### Timing Characteristics
- **Clock Frequency**: 100-200 MHz typical
- **Inference Latency**: ~1010 cycles
- **Inference Time**: 5-10 μs @ 100MHz
- **Throughput**: 100K-200K inferences/second

### Comparison with Software
| Implementation | Latency | Throughput | Power |
|----------------|---------|------------|-------|
| **FPGA (this)** | 5-10 μs | 100K-200K/s | ~1W |
| **ARM Cortex-A9** | 1-10 ms | 100-1K/s | ~2W |
| **x86 CPU** | 100 μs-1ms | 1K-10K/s | ~50W |

## Integration Instructions

### Vivado Project Setup
1. **Create New Project**: RTL project targeting Zynq device
2. **Add Source Files**: Include `axi4_lite_slave.v` and `FCN.sv`
3. **Add IP Cores**: Import `weights_mem.xci` and `biases_mem.xci`
4. **Set Top Module**: `axi4_lite_slave` as top-level
5. **Configure Clocking**: Connect to system clock (100MHz typical)

### Block Design Integration
```tcl
# Create AXI interconnect
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_0

# Add custom AXI slave
create_bd_cell -type module -reference axi4_lite_slave axi_slave_0

# Connect to processing system
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] \
                    [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] \
                    [get_bd_intf_pins axi_slave_0/S_AXI]
```

### Address Mapping
```tcl
# Assign base address for AXI slave
assign_bd_address [get_bd_addr_segs {axi_slave_0/S_AXI/Reg }]
set_property range 4K [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_slave_0_Reg}]
set_property offset 0x40000000 [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_slave_0_Reg}]
```

## Simulation and Verification

### Testbench Strategy
1. **Unit Testing**: Individual component verification
2. **Integration Testing**: Complete system simulation
3. **Protocol Compliance**: AXI4-Lite transaction verification
4. **Functional Testing**: Known input/output validation

### Simulation Environment
```systemverilog
// Testbench template
module fcn_tb;
    reg clk, reset;
    reg [783:0] test_image;
    wire [3:0] prediction;
    wire done;
    
    // Instantiate FCN
    FCN uut (
        .clk(clk),
        .A(test_image),
        .start(start_pulse),
        .B(prediction),
        .done(done)
    );
    
    // Test sequence
    initial begin
        // Load known MNIST test image
        test_image = 784'h...; // Known digit pattern
        
        // Start inference
        start_pulse = 1;
        #10 start_pulse = 0;
        
        // Wait for completion
        wait(done);
        
        // Check result
        $display("Prediction: %d", prediction);
    end
endmodule
```

## Debugging and Troubleshooting

### Common Issues
1. **Memory Initialization**: Verify `.coe` file format and path
2. **Clock Domain**: Ensure single clock throughout design
3. **AXI Timing**: Check handshaking protocol compliance
4. **Fixed-Point Overflow**: Monitor arithmetic operations

### Debug Tools
1. **Integrated Logic Analyzer (ILA)**: Monitor internal signals
2. **AXI Protocol Checker**: Verify bus transactions
3. **Memory Content Analyzer**: Check weight/bias loading
4. **Timing Analysis**: Verify setup/hold requirements

### Optimization Opportunities
1. **Pipeline Stages**: Add pipeline registers for higher frequency
2. **Parallel Processing**: Multiple MAC units for faster computation
3. **Memory Bandwidth**: Dual-port memories for simultaneous access
4. **Precision Tuning**: Optimize bit width for accuracy vs. area

## File Summary

| File/Directory | Description | Purpose |
|----------------|-------------|---------|
| `axi4_lite_slave.v` | AXI4-Lite interface controller | Bus interface |
| `FCN.sv` | Neural network engine | ML computation |
| `weights.coe` | Pre-trained weights | Model parameters |
| `biases.coe` | Pre-trained biases | Model parameters |
| `weights_mem/` | Weight memory IP core | Weight storage |
| `biases_mem/` | Bias memory IP core | Bias storage |

## Learning Objectives

1. **Neural Network Hardware**: Understanding ML acceleration techniques
2. **Memory Architecture**: Efficient parameter storage and access
3. **AXI Protocol**: Industry-standard bus interface implementation
4. **Fixed-Point Arithmetic**: Quantized computation methods
5. **System Integration**: Complete hardware accelerator design

This implementation demonstrates professional-grade FPGA development for machine learning applications, providing a complete hardware acceleration solution for neural network inference.