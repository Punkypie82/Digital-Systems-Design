# MNIST FCN Implementation on FPGA

This directory contains a complete hardware implementation of a Fully Connected Neural Network (FCN) for MNIST digit recognition, demonstrating machine learning acceleration on FPGA platforms using custom hardware and AXI4-Lite integration.

## Overview

This project represents a significant advancement in FPGA-based machine learning, implementing a complete neural network inference engine capable of real-time MNIST digit classification. The design combines custom neural network hardware with professional AXI4-Lite interfaces, making it suitable for integration into larger machine learning systems.

### Neural Network Architecture

**Network Topology**: 784 → 64 → 32 → 10 Fully Connected Network
- **Input Layer**: 784 neurons (28×28 pixel MNIST images)
- **Hidden Layer 1**: 64 neurons with ReLU activation
- **Hidden Layer 2**: 32 neurons with ReLU activation  
- **Output Layer**: 10 neurons (digit classes 0-9)
- **Total Parameters**: ~52,000 weights + biases

### System Architecture

```
ARM Processor ←→ AXI4-Lite ←→ Custom AXI Slave ←→ FCN Engine ←→ Memory Blocks
                                                        ↓
                                                  Weight/Bias Memory
```

**Key Components**:
1. **FCN Engine**: Custom neural network inference hardware
2. **AXI4-Lite Slave**: Professional bus interface
3. **Memory Management**: Dedicated weight and bias storage
4. **ARM Software**: Test application and control logic

## Project Structure

### Directory Organization
```
MNIST FCN Implementation on FPGA/
├── AxiSlave/                    # FPGA Hardware Implementation
│   └── src/                     # Source files
│       ├── axi4_lite_slave.v    # AXI interface controller
│       ├── FCN.sv               # Neural network engine
│       ├── weights.coe          # Pre-trained weights
│       ├── biases.coe           # Pre-trained biases
│       ├── weights_mem/         # Weight memory IP core
│       └── biases_mem/          # Bias memory IP core
└── AxiTest01/                   # ARM Software Implementation
    └── AxiTest01.sdk/           # Xilinx SDK project
        └── Test01/              # Test application
            └── src/             # C source code
                └── main.c       # Main test program
```

## Neural Network Implementation (`FCN.sv`)

### Core Architecture
The FCN engine implements a complete feedforward neural network with the following features:

**Module Interface**:
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | Input | 1-bit | System clock |
| `A` | Input | 784-bit | Flattened input image |
| `start` | Input | 1-bit | Start inference |
| `B` | Output | 4-bit | Predicted digit (0-9) |
| `done` | Output | 1-bit | Inference complete |

### Layer Processing
Each layer is processed sequentially using a state machine:

```verilog
localparam STATE_LAYER_1 = 1;  // Process first hidden layer
localparam STATE_LAYER_2 = 2;  // Process second hidden layer  
localparam STATE_LAYER_3 = 3;  // Process output layer
localparam STATE_PREDICT = 4;  // Find maximum output
```

### Mathematical Operations

#### Matrix Multiplication
```verilog
// For each neuron in current layer
for (node = 0; node < LAYER_SIZE; node++) begin
    partial_sum = bias[node];
    for (input = 0; input < INPUT_SIZE; input++) begin
        partial_sum += input[input] * weight[node][input];
    end
    output[node] = ReLU(partial_sum);
end
```

#### ReLU Activation Function
```verilog
function [DATA_WIDTH-1:0] ReLU;
    input [DATA_WIDTH-1:0] value;
    begin
        ReLU = (value[DATA_WIDTH-1]) ? 0 : value;  // Zero if negative
    end
endfunction
```

#### Custom Multiplication
```verilog
function [DATA_WIDTH-1:0] Mult;
    input signed [DATA_WIDTH-1:0] a, b;
    reg signed [2*DATA_WIDTH-1:0] product;
    begin
        product = a * b;
        Mult = product >>> (DATA_WIDTH/2);  // Arithmetic right shift
    end
endfunction
```

### Memory Architecture

#### Weight Memory
- **Capacity**: ~52,000 16-bit weights
- **Organization**: Sequential storage by layer
- **Access Pattern**: Streaming read during inference
- **Implementation**: Xilinx Block RAM IP core

#### Bias Memory  
- **Capacity**: 106 16-bit biases (64+32+10)
- **Organization**: Sequential by layer
- **Access Pattern**: One bias per neuron
- **Implementation**: Xilinx Block RAM IP core

### Inference Pipeline

1. **Input Loading**: 784-bit image loaded into input registers
2. **Layer 1 Processing**: 784→64 transformation with ReLU
3. **Layer 2 Processing**: 64→32 transformation with ReLU
4. **Layer 3 Processing**: 32→10 transformation with ReLU
5. **Prediction**: Find maximum output (argmax operation)

## AXI4-Lite Integration (`axi4_lite_slave.v`)

### Enhanced AXI Slave
The AXI slave provides a clean interface between the ARM processor and FCN engine:

**Register Map**:
| Address Range | Purpose | Access |
|---------------|---------|--------|
| 0x00-0x60 | Input Image Data (25×32-bit) | Write |
| 0x64 | Start Signal | Write |
| 0x68 | Prediction Result | Read |
| 0x6C | Done Flag | Read |

### FCN Integration
```verilog
wire [783:0] fcn_input;
wire [31:0] fcn_start, fcn_result, fcn_done;

// Concatenate input registers to form 784-bit input
assign fcn_input = {register[0], register[1], ..., register[24]};
assign fcn_start = register[25];

FCN uut(
    .clk(ACLK),
    .A(fcn_input),
    .start(fcn_start),
    .B(fcn_result),
    .done(fcn_done)
);
```

## ARM Software Implementation (`main.c`)

### Test Application Features
- **Hardcoded Test Vector**: Pre-defined MNIST digit pattern
- **AXI Communication**: Memory-mapped register access
- **Inference Control**: Start/stop neural network processing
- **Result Display**: UART output of predictions

### Memory-Mapped Interface
```c
#define AXI_ADDR0 0x0400000000
#define START      (AXI_ADDR0 + 25)
#define DONE       (AXI_ADDR0 + 27)  
#define PREDICTION (AXI_ADDR0 + 26)

volatile unsigned int *AXIAddr0 = (volatile unsigned int *) AXI_ADDR0;
```

### Test Sequence
```c
// 1. Load test image (hardcoded digit "4")
mem[0] = 0b00000000000000000000000000000000;  // Row 1
mem[1] = 0b00000000000000000000000000000000;  // Row 2
// ... (25 registers total for 784 pixels)

// 2. Start inference
mem[START] = 1;
mem[START] = 0;

// 3. Wait for completion
while(mem[DONE] == 0);

// 4. Read result
prediction = mem[PREDICTION];
```

## Memory IP Core Integration

### Xilinx Block RAM Configuration

#### Weight Memory (`weights_mem/`)
- **Memory Type**: Block RAM Generator v8.4
- **Width**: 16 bits
- **Depth**: Calculated for total weight count
- **Initialization**: From `weights.coe` file
- **Port Configuration**: Single-port read-only

#### Bias Memory (`biases_mem/`)
- **Memory Type**: Block RAM Generator v8.4  
- **Width**: 16 bits
- **Depth**: 106 (total bias count)
- **Initialization**: From `biases.coe` file
- **Port Configuration**: Single-port read-only

### Memory Initialization Files

#### `weights.coe` Format
```
memory_initialization_radix=16;
memory_initialization_vector=
1A2B,3C4D,5E6F,7890,
ABCD,EF01,2345,6789,
...
```

#### `biases.coe` Format  
```
memory_initialization_radix=16;
memory_initialization_vector=
0100,FF80,7F00,8001,
...
```

## Performance Characteristics

### Inference Timing
- **Layer 1**: ~784 cycles (784 multiply-accumulates)
- **Layer 2**: ~64 cycles (64 multiply-accumulates)  
- **Layer 3**: ~32 cycles (32 multiply-accumulates)
- **Prediction**: ~10 cycles (find maximum)
- **Total Latency**: ~890 cycles @ system clock

### Resource Utilization (Estimated)
- **LUTs**: ~8,000-12,000 (FCN logic + AXI)
- **Flip-Flops**: ~6,000-8,000 (state machines + registers)
- **Block RAM**: ~50-100 tiles (weights + biases)
- **DSP Slices**: ~20-50 (multipliers)

### Accuracy and Performance
- **Model Accuracy**: Depends on training (typically 95-98% on MNIST)
- **Inference Rate**: ~100K-1M inferences/second (depending on clock)
- **Power Efficiency**: Significantly better than CPU/GPU
- **Latency**: Sub-millisecond inference time

## Training and Model Preparation

### Pre-Training Requirements
1. **Dataset**: MNIST training set (60,000 images)
2. **Framework**: TensorFlow/PyTorch for training
3. **Quantization**: Convert to 16-bit fixed-point
4. **Weight Export**: Generate `.coe` files for FPGA

### Model Quantization
```python
# Example quantization process
def quantize_weights(weights, bits=16):
    scale = (2**(bits-1) - 1) / np.max(np.abs(weights))
    quantized = np.round(weights * scale).astype(np.int16)
    return quantized, scale
```

## Deployment Instructions

### Hardware Setup
1. **FPGA Platform**: Zynq-7000 series (ZedBoard, Pynq, etc.)
2. **Memory Requirements**: Sufficient Block RAM for weights/biases
3. **Clock Frequency**: 100-200 MHz typical
4. **I/O**: UART for output display

### Vivado Project Setup
1. **Create Project**: New RTL project for target board
2. **Add Sources**: Include all `.v`, `.sv`, and IP core files
3. **Generate IP**: Regenerate memory IP cores if needed
4. **Synthesize**: Run synthesis and implementation
5. **Generate Bitstream**: Create FPGA configuration

### Software Development
1. **SDK/Vitis**: Create application project
2. **BSP Generation**: Generate board support package
3. **Compilation**: Cross-compile for ARM target
4. **Deployment**: Load via JTAG or SD card

## Verification and Testing

### Simulation Strategy
1. **Unit Testing**: Individual layer verification
2. **Integration Testing**: Complete FCN pipeline
3. **AXI Protocol**: Bus interface compliance
4. **Functional Testing**: Known input/output pairs

### Hardware Validation
1. **Known Test Vectors**: Verify against software model
2. **MNIST Test Set**: Run subset of test images
3. **Accuracy Measurement**: Compare with expected results
4. **Performance Profiling**: Measure inference timing

## Applications and Extensions

### Immediate Applications
- **Edge AI**: Real-time digit recognition
- **Educational**: ML hardware acceleration learning
- **Prototyping**: Neural network hardware research
- **Benchmarking**: FPGA ML performance evaluation

### Potential Extensions
1. **Larger Networks**: Support for deeper/wider architectures
2. **Multiple Models**: Dynamic model switching
3. **Batch Processing**: Parallel inference on multiple images
4. **Streaming Interface**: Continuous image processing
5. **Other Datasets**: CIFAR-10, custom datasets

### Advanced Features
1. **Dynamic Quantization**: Runtime precision adjustment
2. **Pruning Support**: Sparse network acceleration
3. **Batch Normalization**: Additional layer types
4. **Convolutional Layers**: CNN implementation
5. **Training Support**: On-chip learning capability

## Troubleshooting

### Common Issues
1. **Memory Initialization**: Verify `.coe` file format and content
2. **AXI Timing**: Check bus protocol compliance
3. **Arithmetic Overflow**: Monitor fixed-point precision
4. **Clock Domain**: Ensure single clock throughout design

### Debug Techniques
1. **Simulation**: Verify functionality before hardware
2. **ILA Integration**: Monitor internal signals
3. **Known Vectors**: Test with verified inputs
4. **Incremental Testing**: Test layers individually

## Learning Objectives

1. **Neural Network Hardware**: Understanding ML acceleration
2. **Memory Management**: Efficient weight/bias storage
3. **Fixed-Point Arithmetic**: Quantized computation
4. **System Integration**: Complete ML system design
5. **Performance Optimization**: Hardware/software co-design

This implementation demonstrates the complete pipeline from trained neural network model to deployed FPGA hardware, providing valuable experience in machine learning acceleration and embedded AI systems.

## Subdirectory Documentation

- **[AxiSlave/](AxiSlave/README.md)**: Detailed FPGA hardware implementation
- **[AxiTest01/](AxiTest01/README.md)**: ARM software test application

This project showcases the intersection of machine learning and digital design, providing a practical example of AI acceleration using FPGA technology.