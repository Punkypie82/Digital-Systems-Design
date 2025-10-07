# AxiTest01 - ARM Software Test Application

This directory contains the ARM processor software implementation for testing and controlling the MNIST FCN hardware accelerator, demonstrating hardware-software co-design principles in Zynq-based systems.

## Overview

The AxiTest01 application provides a complete software framework for interfacing with the FPGA-based neural network accelerator. It demonstrates professional embedded software development practices for machine learning applications, including memory-mapped I/O, real-time inference control, and result processing.

## Directory Structure

```
AxiTest01/
└── AxiTest01.sdk/                    # Xilinx SDK workspace
    └── Test01/                       # Application project
        └── src/                      # Source code directory
            └── main.c                # Main application code
```

## Software Architecture

### System Integration
```
ARM Cortex-A9 ←→ AXI4-Lite Interconnect ←→ Custom FCN Accelerator
      ↓                                              ↓
   main.c Application                         Neural Network Engine
```

### Key Components
1. **Memory-Mapped Interface**: Direct hardware register access
2. **Test Vector Management**: Hardcoded MNIST digit patterns
3. **Inference Control**: Start/stop neural network processing
4. **Result Processing**: Prediction extraction and display
5. **Continuous Testing**: Automated testing loop

## Implementation Details (`main.c`)

### Memory Mapping Configuration
```c
#define AXI_ADDR0 0x0400000000              // Base address for AXI slave
volatile unsigned int *AXIAddr0 = (volatile unsigned int *) AXI_ADDR0;

// Register definitions
#define START      (AXI_ADDR0 + 25)         // Start inference register
#define DONE       (AXI_ADDR0 + 27)         // Completion status register  
#define PREDICTION (AXI_ADDR0 + 26)         // Result register
```

### Hardware Interface
The software communicates with the FPGA through a 32-register memory-mapped interface:

| Register Index | Address Offset | Purpose | Access |
|----------------|----------------|---------|--------|
| 0-24 | 0x00-0x60 | Input Image Data | Write |
| 25 | 0x64 | Start Signal | Write |
| 26 | 0x68 | Prediction Result | Read |
| 27 | 0x6C | Done Flag | Read |

### Test Image Data

The application includes a hardcoded test pattern representing the digit "4":

```c
// 784-bit MNIST image data (28×28 pixels) stored across 25 registers
// Each register holds 32 bits, total 800 bits (784 used)

mem[AXI_ADDR0+0] = 0b00000000000000000000000000000000;   // Row 1-2 (top border)
mem[AXI_ADDR0+1] = 0b00000000000000000000000000000000;   // Row 3-4
mem[AXI_ADDR0+2] = 0b00000000000000000000000000000000;   // Row 5-6
mem[AXI_ADDR0+3] = 0b00000000000000000000000000000000;   // Row 7-8
mem[AXI_ADDR0+4] = 0b00000000000000000000000000000000;   // Row 9-10
mem[AXI_ADDR0+5] = 0b00000000000000000000000000000000;   // Row 11-12
mem[AXI_ADDR0+6] = 0b00000000000000000000000000000000;   // Row 13-14
mem[AXI_ADDR0+7] = 0b00000000000000000000000000000001;   // Row 15-16 (digit starts)

// Digit "4" pattern continues...
mem[AXI_ADDR0+8] = 0b10000000000000000000001000011000;   // Vertical line + horizontal
mem[AXI_ADDR0+9] = 0b00000000000000000110000110000000;   // Intersection pattern
// ... (continues for remaining rows)

mem[AXI_ADDR0+24] = 0b00000000000000000000000000000000;  // Bottom border
```

### Image Data Organization
The 28×28 MNIST image is flattened into a 784-bit vector and packed into 25 32-bit registers:

```
Pixel Layout (28×28):
Row 0:  [P0,   P1,   P2,   ..., P27 ]
Row 1:  [P28,  P29,  P30,  ..., P55 ]
...
Row 27: [P756, P757, P758, ..., P783]

Register Packing:
register[0]  = {P31,  P30,  P29,  ..., P0  }  // First 32 pixels
register[1]  = {P63,  P62,  P61,  ..., P32 }  // Next 32 pixels
...
register[24] = {0,0,0,0,0,0,0,0,P783,...,P768} // Last 16 pixels + padding
```

### Inference Control Flow

#### Main Application Loop
```c
int main() {
    unsigned int *mem = AXI_ADDR0;
    unsigned int out;

    for(;;) {                                    // Infinite test loop
        xil_printf("--------------------------------\n\r");
        
        // 1. Load test image data
        load_test_image(mem);
        xil_printf("Setting Input 4\n\r\n\r");
        
        // 2. Start inference
        mem[START] = 1;                          // Assert start signal
        xil_printf("Assert Start\n\r");
        mem[START] = 0;                          // Deassert start signal
        xil_printf("Deassert Start\n\r\n\r");
        
        // 3. Wait for completion
        while(mem[DONE] == 0);                   // Poll done flag
        
        // 4. Read and display result
        out = mem[PREDICTION];
        xil_printf("Prediction: %d\n\r", out);
        
        // 5. Delay before next test
        sleep(5);
    }
}
```

#### Handshaking Protocol
```
1. ARM writes image data to registers 0-24
2. ARM asserts start signal (register 25 = 1)
3. ARM deasserts start signal (register 25 = 0)
4. FPGA processes inference (hardware state machine)
5. ARM polls done flag (register 27) until set
6. ARM reads prediction result (register 26)
7. Repeat for next inference
```

### Communication Protocol Details

#### Write Transaction Sequence
```c
// Image data loading (25 write transactions)
for (int i = 0; i < 25; i++) {
    mem[AXI_ADDR0 + i] = image_data[i];      // AXI write transaction
}

// Control signal (2 write transactions)
mem[START] = 1;                              // Start pulse
mem[START] = 0;                              // Release
```

#### Read Transaction Sequence
```c
// Status polling (multiple read transactions)
while (mem[DONE] == 0) {                     // Poll until done
    // Hardware may take 1000+ cycles for inference
}

// Result retrieval (1 read transaction)  
unsigned int prediction = mem[PREDICTION];    // Get result (0-9)
```

### Expected Output Format

#### Console Output Example
```
--------------------------------
Setting Input 4

Assert Start
Deassert Start

Prediction: 4
--------------------------------
Setting Input 4

Assert Start  
Deassert Start

Prediction: 4
```

#### Timing Characteristics
- **Image Loading**: ~25 AXI write transactions (~100-500 cycles)
- **Inference Time**: ~1000 cycles (hardware dependent)
- **Result Reading**: ~2 AXI read transactions (~10-50 cycles)
- **Total Cycle Time**: ~1100-1550 cycles per inference
- **Real Time**: ~5-15 μs @ 100MHz system clock

## Development Environment

### Xilinx SDK/Vitis Configuration
```
Project Type:     Application Project
Target Platform:  Zynq-7000 series
Processor:        ARM Cortex-A9
Language:         C
Template:         Hello World (modified)
```

### Board Support Package (BSP)
```
OS Platform:      Standalone (bare-metal)
Processor:        ps7_cortexa9_0
Libraries:        xilffs, xilrsa, xilsecure (optional)
Drivers:          Generic drivers for Zynq PS
```

### Compilation Settings
```c
// Compiler flags (typical)
-O2                    // Optimization level 2
-g                     // Debug information
-Wall                  // All warnings
-mcpu=cortex-a9       // Target processor
-mfpu=vfpv3           // Floating point unit
```

### Memory Map (Zynq-7000)
```
DDR Memory:       0x00000000 - 0x3FFFFFFF (1GB)
OCM Memory:       0xFFFC0000 - 0xFFFFFFFF (256KB)
AXI Slave:        0x40000000 - 0x40000FFF (4KB)
Peripheral Base:  0xE0000000 - 0xFFFFFFFF
```

## Integration with Hardware

### AXI4-Lite Transaction Details

#### Write Transaction Timing
```
Clock Cycle:  1    2    3    4    5
AWVALID:      0    1    1    0    0
AWREADY:      0    0    1    0    0  
WVALID:       0    1    1    0    0
WREADY:       0    0    1    0    0
BVALID:       0    0    0    1    0
BREADY:       1    1    1    1    0
```

#### Read Transaction Timing  
```
Clock Cycle:  1    2    3    4    5
ARVALID:      0    1    1    0    0
ARREADY:      0    0    1    0    0
RVALID:       0    0    0    1    0  
RREADY:       1    1    1    1    0
RDATA:        X    X    X  DATA   X
```

### Performance Optimization

#### Memory Access Patterns
```c
// Efficient: Sequential register access
for (int i = 0; i < 25; i++) {
    mem[i] = image_data[i];              // Cache-friendly access
}

// Less efficient: Random access
mem[24] = image_data[24];
mem[0] = image_data[0];
mem[12] = image_data[12];               // Cache misses possible
```

#### Polling Optimization
```c
// Basic polling (CPU intensive)
while (mem[DONE] == 0);

// Optimized polling with delay
while (mem[DONE] == 0) {
    usleep(1);                          // Yield CPU briefly
}

// Interrupt-driven (advanced)
// Requires hardware interrupt support
```

## Testing and Validation

### Test Vector Validation
The hardcoded test image represents a specific MNIST digit "4" pattern:
```
Expected Result: 4 (digit classification)
Confidence: High (depends on model accuracy)
Alternative Results: 1, 7, 9 (possible misclassifications)
```

### Verification Methods

#### Functional Testing
1. **Known Input**: Use verified MNIST test image
2. **Expected Output**: Compare with software model prediction
3. **Consistency**: Multiple runs should produce same result
4. **Timing**: Verify inference completes within expected time

#### Performance Testing
```c
// Timing measurement example
#include "xtime_l.h"

XTime start_time, end_time;
XTime_GetTime(&start_time);

// Perform inference
mem[START] = 1;
mem[START] = 0;
while(mem[DONE] == 0);

XTime_GetTime(&end_time);
double inference_time = (double)(end_time - start_time) / XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ;
xil_printf("Inference time: %f seconds\n\r", inference_time);
```

#### Stress Testing
```c
// Continuous operation test
for (int test_count = 0; test_count < 10000; test_count++) {
    // Run inference
    mem[START] = 1;
    mem[START] = 0;
    while(mem[DONE] == 0);
    
    unsigned int result = mem[PREDICTION];
    if (result != 4) {
        xil_printf("ERROR: Test %d failed, got %d\n\r", test_count, result);
    }
    
    if (test_count % 1000 == 0) {
        xil_printf("Completed %d tests\n\r", test_count);
    }
}
```

## Extensions and Enhancements

### Dynamic Image Loading
```c
// Load image from file system
#include "ff.h"  // FatFS library

int load_mnist_image(const char* filename, unsigned int* registers) {
    FIL file;
    FRESULT result = f_open(&file, filename, FA_READ);
    if (result != FR_OK) return -1;
    
    unsigned char pixel_data[784];
    UINT bytes_read;
    f_read(&file, pixel_data, 784, &bytes_read);
    f_close(&file);
    
    // Convert to register format
    pack_pixels_to_registers(pixel_data, registers);
    return 0;
}
```

### Multiple Model Support
```c
// Model selection interface
typedef enum {
    MODEL_MNIST_FCN,
    MODEL_CIFAR_CNN,
    MODEL_CUSTOM
} model_type_t;

int select_model(model_type_t model) {
    mem[MODEL_SELECT] = model;
    return 0;
}
```

### Batch Processing
```c
// Process multiple images
int batch_inference(unsigned int images[][25], int count, unsigned int* results) {
    for (int i = 0; i < count; i++) {
        // Load image i
        for (int j = 0; j < 25; j++) {
            mem[j] = images[i][j];
        }
        
        // Run inference
        mem[START] = 1;
        mem[START] = 0;
        while(mem[DONE] == 0);
        
        // Store result
        results[i] = mem[PREDICTION];
    }
    return count;
}
```

### Error Handling
```c
// Timeout protection
#include "xtime_l.h"

int inference_with_timeout(unsigned int timeout_ms) {
    XTime start_time, current_time;
    XTime_GetTime(&start_time);
    
    mem[START] = 1;
    mem[START] = 0;
    
    while(mem[DONE] == 0) {
        XTime_GetTime(&current_time);
        double elapsed = (double)(current_time - start_time) / XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ * 1000;
        
        if (elapsed > timeout_ms) {
            xil_printf("ERROR: Inference timeout\n\r");
            return -1;  // Timeout error
        }
    }
    
    return mem[PREDICTION];
}
```

## Debugging and Troubleshooting

### Common Issues

#### Memory Access Errors
```c
// Check AXI base address
if (AXIAddr0 == NULL) {
    xil_printf("ERROR: Invalid AXI base address\n\r");
    return -1;
}

// Verify register access
volatile unsigned int test_val = 0xDEADBEEF;
mem[0] = test_val;
if (mem[0] != test_val) {
    xil_printf("ERROR: Register write/read failed\n\r");
}
```

#### Timing Issues
```c
// Add delays for hardware settling
mem[START] = 1;
usleep(10);              // 10μs delay
mem[START] = 0;

// Verify done flag behavior
int timeout_count = 0;
while(mem[DONE] == 0) {
    timeout_count++;
    if (timeout_count > 1000000) {
        xil_printf("ERROR: Hardware not responding\n\r");
        break;
    }
}
```

#### Data Integrity
```c
// Verify image data loading
for (int i = 0; i < 25; i++) {
    unsigned int written = image_data[i];
    unsigned int read_back = mem[i];
    if (written != read_back) {
        xil_printf("ERROR: Register %d mismatch: wrote 0x%08X, read 0x%08X\n\r", 
                   i, written, read_back);
    }
}
```

### Debug Output
```c
// Verbose debugging mode
#define DEBUG_VERBOSE 1

#if DEBUG_VERBOSE
    xil_printf("Loading image data...\n\r");
    for (int i = 0; i < 25; i++) {
        xil_printf("Register[%d] = 0x%08X\n\r", i, mem[i]);
    }
    
    xil_printf("Starting inference...\n\r");
    xil_printf("Done flag: %d\n\r", mem[DONE]);
    xil_printf("Prediction: %d\n\r", mem[PREDICTION]);
#endif
```

## File Summary

| File | Description | Purpose |
|------|-------------|---------|
| `main.c` | Main application code | Software control and testing |

## Learning Objectives

1. **Embedded Software Development**: Bare-metal ARM programming
2. **Memory-Mapped I/O**: Hardware register interface programming
3. **AXI Protocol Usage**: Software perspective of bus transactions
4. **Hardware-Software Interface**: Co-design communication protocols
5. **Real-Time Systems**: Timing-critical embedded applications

This software implementation demonstrates professional embedded software development practices for machine learning applications, providing a complete framework for controlling and testing FPGA-based neural network accelerators.