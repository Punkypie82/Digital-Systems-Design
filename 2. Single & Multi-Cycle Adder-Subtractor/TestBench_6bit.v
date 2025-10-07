`timescale 1ns/1ps

module AdderSubtractor_tb;
    reg [5:0] A;
    reg [5:0] B;
    reg rst;
    reg addsub;
    reg start;
    reg clk;

    wire [5:0] sum;
    wire cout;
    wire done;
    wire calculating;

    AdderSubtractor #(6) uut (
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

        A = 6'b000001; // A = 1
        B = 6'b000001; // B = 1
        addsub = 0;    // addition
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b100011; // A = -29
        B = 6'b011010; // B = 26
        addsub = 0;        // addition
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b010110; // A = 22
        B = 6'b001001; // B = 9
        addsub = 1;        // subtraction
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b111111; // A = -1
        B = 6'b000001; // B = 1
        addsub = 0;        // addition
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b011011; // A = 27
        B = 6'b010101; // B = 21
        addsub = 1;        // subtraction
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b101101; // A = -19
        B = 6'b100110; // B = -26
        addsub = 0;        // addition
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b000110; // A = 6
        B = 6'b000001; // B = 1
        addsub = 1;        // subtraction
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b110001; // A = -31
        B = 6'b001001; // B = 9
        addsub = 1;        // subtraction
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b101011; // A = -21
        B = 6'b011001; // B = 25
        addsub = 0;        // addition
        start = 1;
        #10;
        start = 0;
        #70;

        A = 6'b010111; // A = 23
        B = 6'b000111; // B = 7
        addsub = 1;        // subtraction
        start = 1;
        #10;
        start = 0;
        #70;
    end
endmodule
