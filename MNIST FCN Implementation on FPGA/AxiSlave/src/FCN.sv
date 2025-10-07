`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2025 08:08:38 PM
// Design Name: 
// Module Name: FCN
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FCN(
    input  clk,
    input  [783:0] A,
    input  start,
    output reg [3:0] B,
    output reg done
    );
    
    localparam DATA_WIDTH = 16;
    
    localparam STATE_LAYER_1 = 1;
    localparam STATE_LAYER_2 = 2;
    localparam STATE_LAYER_3 = 3;
    localparam STATE_PREDICT = 4;
    
    reg [2:0] state;
    
    reg [DATA_WIDTH-1:0] weight_addr;
    reg [DATA_WIDTH-1:0] bias_addr;
    wire [DATA_WIDTH-1:0] weight;
    wire [DATA_WIDTH-1:0] bias;
    
    reg [1:0] read_en;
    
    weights_mem weights (
        .clka(clk),
        .wea(0),
        .addra(weight_addr),
        .dina(16'b0),
        .douta(weight)
    );
    
    biases_mem biases (
        .clka(clk),
        .wea(0),
        .addra(bias_addr),
        .dina(16'b0),
        .douta(bias)
    );
    
    reg state_processing;
    
    localparam LAYER_0_SIZE = 784;
    localparam LAYER_1_SIZE = 64;
    localparam LAYER_2_SIZE = 32;
    localparam LAYER_3_SIZE = 10;
    
    reg [DATA_WIDTH-1 : 0] layer_1_output [0 : LAYER_1_SIZE-1];
    reg [DATA_WIDTH-1 : 0] layer_2_output [0 : LAYER_2_SIZE-1];
    reg [DATA_WIDTH-1 : 0] layer_3_output [0 : LAYER_3_SIZE-1];
    reg [DATA_WIDTH-1 : 0] partial_output;
    
    integer node_counter;
    integer weight_counter;
    integer i, j, k;
    
    always @(posedge clk) begin
        if (start && (state_processing == 0 || state_processing ===1'bx)) begin
            state <= STATE_LAYER_1;
            state_processing <= 1;
            node_counter     <= 0;
            weight_counter   <= 0;
            weight_addr      <= 0;
            bias_addr        <= 0;
            done             <= 0;
            read_en          <= 0;
            for (i = 0; i < LAYER_1_SIZE; i = i + 1)
                layer_1_output[i] = 16'b0;
            for (j = 0; j < LAYER_2_SIZE; j = j + 1)
                layer_2_output[i] = 16'b0;
            for (k = 0; k < LAYER_3_SIZE; k = k + 1)
                layer_3_output[i] = 16'b0;
        end
        else if (state_processing) begin
            case(state)
                // Layer 1
                STATE_LAYER_1: begin
                    if (weight_counter == 0) begin
                        if (read_en == 3) begin
                            partial_output <= bias;
                            weight_counter <= 1;
                        end
                        read_en <= read_en + 1;
                    end
                    else if (weight_counter == LAYER_0_SIZE + 1) begin
                        if (node_counter == LAYER_1_SIZE - 1) begin
                            state <= STATE_LAYER_2;
                            node_counter <= 0;
                        end
                        else
                            node_counter <= node_counter + 1;
                        bias_addr <= bias_addr + 1;
                        layer_1_output[node_counter] <= ReLU(partial_output);
                        weight_counter <= 0;
                    end
                    else begin
                        if (read_en == 3) begin
                            partial_output <= partial_output + (A[LAYER_0_SIZE - weight_counter] ? (weight) : 0);
                            weight_counter <= weight_counter + 1;
                            weight_addr <= weight_addr + 1;
                        end
                        read_en <= read_en + 1;
                    end
                end
                // Layer 2
                STATE_LAYER_2: begin
                    if (weight_counter == 0) begin
                        if (read_en == 3) begin
                            partial_output <= bias;
                            weight_counter <= 1;
                        end
                        read_en <= read_en + 1;
                    end
                    else if (weight_counter == LAYER_1_SIZE + 1) begin
                        if (node_counter == LAYER_2_SIZE - 1) begin
                            state <= STATE_LAYER_3;
                            node_counter <= 0;
                        end
                        else 
                            node_counter <= node_counter + 1;
                        bias_addr <= bias_addr + 1;
                        layer_2_output[node_counter] <= ReLU(partial_output);
                        weight_counter <= 0;
                    end
                    else begin
                        if (read_en == 3) begin
                            partial_output <= partial_output + Mult(layer_1_output[weight_counter-1], weight);
                            weight_counter <= weight_counter + 1;
                            weight_addr <= weight_addr + 1;
                        end
                        read_en <= read_en + 1;
                    end
                end
                // Layer 3
                STATE_LAYER_3: begin
                    if (weight_counter == 0) begin
//                        B <= {layer_1_output[3], layer_1_output[4]};
//                        state_processing <= 0;
//                        done <= 1;
                        if (read_en == 3) begin
                            partial_output <= bias;
                            weight_counter <= 1;
                        end
                        read_en <= read_en + 1;
                    end
                    else if (weight_counter == LAYER_2_SIZE + 1) begin
                        if (node_counter == LAYER_3_SIZE - 1) begin
                            state <= STATE_PREDICT;
                            node_counter <= 0;
                        end
                        else
                            node_counter <= node_counter + 1;
                        bias_addr <= bias_addr + 1;
                        layer_3_output[node_counter] <= ReLU(partial_output);
                        weight_counter <= 0;
                    end
                    else begin
                        if (read_en == 3) begin
                            partial_output <= partial_output + Mult(layer_2_output[weight_counter-1], weight);
                            weight_counter <= weight_counter + 1;
                            weight_addr <= weight_addr + 1;
                        end
                        read_en <= read_en + 1;
                    end
                end
                // Predict
                STATE_PREDICT: begin
                    if (weight_counter == 0) begin
                        weight_counter <= 1;
                        node_counter <= 0;
                        partial_output <= 0;
                    end
                    else if (node_counter < LAYER_3_SIZE) begin
                        if (partial_output < layer_3_output[node_counter]) begin
                            partial_output <= layer_3_output[node_counter];
                            B <= node_counter;
                        end
                        node_counter <= node_counter + 1;
                    end
                    else begin
                        state_processing <= 0;
                        done <= 1;
                    end
                end
            endcase
        end
    end
    
    function [DATA_WIDTH-1 : 0] Mult;
        input signed [DATA_WIDTH-1 : 0] a, b;
        reg signed [2*DATA_WIDTH-1 : 0] product;
        begin
            product = a * b;
            Mult = product >>> (DATA_WIDTH/2);
        end
    endfunction

    function [DATA_WIDTH-1 : 0] ReLU;
        input [DATA_WIDTH-1 : 0] value;
        begin
            ReLU = (value[DATA_WIDTH-1]) ? 0 : value;
        end
    endfunction
endmodule