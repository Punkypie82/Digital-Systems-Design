`timescale 1ns/1ps

module AdderSubtractor_tb;
    reg [7:0] A;
    reg [7:0] B;
    reg rst;
    reg addsub;
    reg start;
    reg clk;

    wire [7:0] sum;
    wire cout;
    wire done;

    AdderSubtractor #(8) uut (
        .A(A),
        .B(B),
        .rst(rst),
        .addsub(addsub),
        .start(start),
        .clk(clk),
        .sum(sum),
        .cout(cout),
        .done(done)
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


//. Single. Cycle .start

  // Test Case 1: A = -128, B = -128, Subtraction
        A = 8'b10000000;  
        B = 8'b10000000;
        addsub = 1;
        start = 1;
        #10;
        start = 0;
        #70;

        // Test Case 2: A = 255, B = 1, Addition
        A = 8'b11111111;
        B = 8'b00000001;
        addsub = 0;
        start = 1;
        #10;
        start = 0;
        #70;

        A = 8'b11001000; // 200
        B = 8'b00110010; // 50
        addsub = 0;
        start = 1;
        #10;
        start = 0;
        #70;


        // Reset signal test
        rst = 1;         // Assert reset
        #10;
        rst = 0;         // Deassert reset

        // Test Case 4: A = 85, B = 51, Addition
        A = 8'b01010101;
        B = 8'b00110011;
        addsub = 0;
        start = 1;
        #10;
        start = 0;
        #70;

        // Test Case 5: A = 170, B = 15, Subtraction
        #10;
        A = 8'b10101010;
        B = 8'b00001111;
        addsub = 1;
        start = 1;
        #10;
        start = 0;
        #70;


        // Test Case 7: A = 127, B = 1, Addition
        #10;
        A = 8'b01111111;
        B = 8'b00000001;
        addsub = 0;
        start = 1;
        #10;
        start = 0;
        #70;

    end
endmodule

