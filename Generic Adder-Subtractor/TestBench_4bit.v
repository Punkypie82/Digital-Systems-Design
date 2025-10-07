`timescale 1ns/1ps

module AdderSubtractor_tb;  // 60 ns
    reg [3:0] A;
    reg [3:0] B;
    reg Op;

    wire [3:0] S;
    wire Cout;

    parameter N = 4;

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

        A = 4'b0010; // A = 2
        B = 4'b0001; // B = 1
        Op = 0;      // addition
        #10;

        A = 4'b1110; // A = -2
        B = 4'b0011; // B = 3
        Op = 0;      // addition
        #10;

        A = 4'b0111; // A = 7
        B = 4'b0011; // B = 3
        Op = 1;      // subtraction
        #10;

        A = 4'b1100; // A = -4
        B = 4'b0100; // B = 4
        Op = 1;      // subtraction
        #10;

        // A = 4'b0111; // A = 7
        // B = 4'b0010; // B = 2
        // Op = 0;      // addition
        // #10;

        A = 4'b0001; // A = 1
        B = 4'b0011; // B = 3
        Op = 1;      // subtraction
        #10;

        // A = 4'b1011; // A = -5
        // B = 4'b1001; // B = -7
        // Op = 0;      // addition
        // #10;

        A = 4'b1111; // A = -1
        B = 4'b1111; // B = -1
        Op = 0;      // addition
        #10;
    end
endmodule
