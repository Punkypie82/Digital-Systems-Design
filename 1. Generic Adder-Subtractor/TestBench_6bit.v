`timescale 1ns/1ps

module AdderSubtractor_tb;  // 90 ns
    reg [11:0] A;
    reg [11:0] B;
    reg Op;

    wire [11:0] S;
    wire Cout;

    parameter N = 12;

    // GateLevelAS #(N) uut (
    // ContinuousAssignmentAS #(N) uut (
    ProceduralConstructAS #(N) uut (
        .A(A), 
        .B(B), 
        .Op(Op), 
        .S(S), 
        .Cout(Cout)
    );

    initial begin

        A = 12'b000001111101; // A = 1
        B = 12'b111110111111; // B = 1
        Op = 1;        // addition
        #10;

        // A = 6'b100011; // A = -29
        // B = 6'b011010; // B = 26
        // Op = 0;        // addition
        // #10;

        // A = 6'b010110; // A = 22
        // B = 6'b001001; // B = 9
        // Op = 1;        // subtraction
        // #10;

        // A = 6'b111111; // A = -1
        // B = 6'b000001; // B = 1
        // Op = 0;        // addition
        // #10;

        // A = 6'b011011; // A = 27
        // B = 6'b010101; // B = 21
        // Op = 1;        // subtraction
        // #10;

        // // A = 6'b101101; // A = -19
        // // B = 6'b100110; // B = -26
        // // Op = 0;        // addition
        // // #10;

        // A = 6'b000110; // A = 6
        // B = 6'b000001; // B = 1
        // Op = 1;        // subtraction
        // #10;

        // A = 6'b110001; // A = -31
        // B = 6'b001001; // B = 9
        // Op = 1;        // subtraction
        // #10;

        // A = 6'b101011; // A = -21
        // B = 6'b011001; // B = 25
        // Op = 0;        // addition
        // #10;

        // A = 6'b010111; // A = 23
        // B = 6'b000111; // B = 7
        // Op = 1;        // subtraction
        // #10;
    end
endmodule
