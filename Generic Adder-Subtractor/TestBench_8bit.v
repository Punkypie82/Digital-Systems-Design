`timescale 1ns/1ps

module AdderSubtractor_tb;  // 90 ns
    reg [7:0] A;
    reg [7:0] B;
    reg Op;

    wire [7:0] S;
    wire Cout;

    parameter N = 8;

    GateLevelAS #(N) uut (
    // ContinuousAssignmentAS #(N) uut (
    // ProceduralConstructAS #(N) uut (
        .A(A), 
        .B(B), 
        .Op(Op), 
        .S(S), 
        .Cout(Cout)
    );

    initial begin

        A = 8'b00000001; // A = 1
        B = 8'b00000001; // B = 1
        Op = 0;          // addition
        #10;

        A = 8'b10000000; // A = -128
        B = 8'b01111111; // B = 127
        Op = 0;          // addition
        #10;

        A = 8'b01100000; // A = 96
        B = 8'b00010000; // B = 16
        Op = 1;          // subtraction
        #10;

        A = 8'b11111111; // A = -1
        B = 8'b00000001; // B = 1
        Op = 0;          // addition
        #10;

        A = 8'b00010010; // A = 18
        B = 8'b00001111; // B = 15
        Op = 1;          // subtraction
        #10;

        // A = 8'b10011110; // A = -98
        // B = 8'b10101010; // B = -86
        // Op = 0;          // addition
        // #10;

        A = 8'b00001000; // A = 8
        B = 8'b00000001; // B = 1
        Op = 1;          // subtraction
        #10;

        A = 8'b11000001; // A = -63
        B = 8'b00000101; // B = 5
        Op = 1;          // subtraction
        #10;

        A = 8'b10110101; // A = -75
        B = 8'b01010110; // B = 86
        Op = 0;          // addition
        #10;

        A = 8'b00111111; // A = 63
        B = 8'b00001111; // B = 15
        Op = 1;          // subtraction
        #10;
    end
endmodule
