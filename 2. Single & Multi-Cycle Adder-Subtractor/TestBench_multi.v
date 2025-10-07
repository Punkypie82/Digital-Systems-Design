`timescale 1ns/1ps

module AdderSubtractor_tb;
    reg [0:0] A;
    reg [0:0] B;
    reg rst;
    reg addsub;
    reg start;
    reg clk;

    wire [0:0] sum;
    wire cout;
    wire done;
    wire calculating;

    AdderSubtractor #(1) uut (
        .A(A),
        .B(B),
        .rst(rst),
        .addsub(addsub),
        .start(start),
        .clk(clk),
        .sum(sum),
        .cout(cout),
        .done(done),
        .calculating(calculating)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        A = 0;
        B = 0;
        addsub = 0;
        start = 0;
        rst = 1;
        #30;
        rst = 0;

        A=1'b0; 
        B=1'b0;
        addsub = 1;       // -
        start = 1;
        #10;
        start = 0;
        #90;

        
//     A = 8'b10000000;  // -128 (signed)
//     B = 8'b10000000;  // -128 (signed)
//     addsub = 1;       // -
//     start = 1;
//     #10;
//     start = 0;
//     #90;


//     A = 8'b11111111;  // 255 (unsigned)
//     B = 8'b00000001;  // 1 (unsigned)
//     addsub = 0;       // +
//     start = 1;
//     #10;
//     start = 0;
//     #90;

//     A = 8'b01111111;  // 127 (signed)
//     B = 8'b10000000;  // -128 (signed)
//     addsub = 1;       // -
//     start = 1;
//     #10;
//     start = 0;
//     #90;

//     #50;
//     rst = 1;
//     #10;
//     rst = 0;         // Deassert reset
//     #10;

//     A = 8'b01010101;  // 85 (unsigned)
//     B = 8'b00110011;  // 51 (unsigned)
//     addsub = 0;       // Addition
//     start = 1;
//     #10;
//     start = 0;
//     #90;

//     A = 8'b10101010;  // 170 (unsigned)
//     B = 8'b00001111;  // 15 (unsigned)
//     addsub = 1;       // Subtraction
//     start = 1;
//     #10;
//     start = 0;
//     #90;


//     A = 8'b00000000;  // 0 (unsigned)
//     B = 8'b00000000;  // 0 (unsigned)
//     addsub = 0;       // +
//     start = 1;
//     #10;
//     start = 0;
//     #90;

//     A = 8'b01111111;  // 127 (signed)
//     B = 8'b00000001;  // 1 (signed)
//     addsub = 0;       // +
//     start = 1;
//     #10;
//     start = 0;
//     #90;

// // start 
//     A <= 8'b00101010;   // 42
//     B <= 8'b00001111;   // 15
//     addsub <= 0;        // +
//     start <= 1;         // Start the operation
//     #10;
//     start = 0;
//     #90;


//     A <= 8'b00000010;   // 2
//     B <= 8'b00000100;   // 4
//     addsub <= 1;        // -
//     start <= 1;         // Start the operation
//     #10;
//     start = 0;
//     #90;

//     A <= 8'b01011000;   // 88
//     B <= 8'b00010110;   // 22
//     addsub <= 1;        // -
//     start <= 1;         // Start the operation
//     #10;
//     start = 0;
//     #90;

//     A <= 8'b00010001;   // 17
//     B <= 8'b00010001;   // 17
//     addsub <= 1;        // -
//     start <= 0;         // Start the operation
//     #10;
//     start = 0;
//     #90;


//     A <= 8'b00011000;   // 24
//     B <= 8'b01000000;   // 64
//     addsub <= 0;        // +
//     start <= 1;         // Start the operation
//     #10;
//     start = 0;
//     #90;


    end
endmodule
