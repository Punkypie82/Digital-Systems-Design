`timescale 1ns/1ps

module TEA_tb;
    reg clk;
    reg nrst;
    reg [31:0] v0_in, v1_in;
    reg [31:0] k0, k1, k2, k3;
    wire [31:0] v0_out, v1_out;

    TEA uut (
        .clk(clk),
        .nrst(nrst),
        .v0_in(v0_in), .v1_in(v1_in),
        .k0(k0), .k1(k1), .k2(k2), .k3(k3),
        .v0_out(v0_out), .v1_out(v1_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        nrst = 0;
        #20;
        nrst = 1;

        v0_in = 32'h01234567;
        v1_in = 32'h89abcdef;
        k0 = 32'h00112233;
        k1 = 32'h44556677;
        k2 = 32'h8899aabb;
        k3 = 32'hccddeeff;
        // #10;

        // v0_in = 32'hdeadbeef;
        // v1_in = 32'hfeedface;
        // k0 = 32'h11223344;
        // k1 = 32'h55667788;
        // k2 = 32'h99aabbcc;
        // k3 = 32'hddeeff00;
        // #10;

        // v0_in = 32'habcdef01;
        // v1_in = 32'h12345678;
        // k0 = 32'h00001111;
        // k1 = 32'h22223333;
        // k2 = 32'h44445555;
        // k3 = 32'h66667777;
        // #10;

        // v0_in = 32'hcafebabe;
        // v1_in = 32'hdeadbeef;
        // k0 = 32'h88889999;
        // k1 = 32'haaaa5555;
        // k2 = 32'h3333cccc;
        // k3 = 32'h99998888;
        // #10;

        // v0_in = 32'h11111111;
        // v1_in = 32'h22222222;
        // k0 = 32'h33333333;
        // k1 = 32'h44444444;
        // k2 = 32'h55555555;
        // k3 = 32'h66666666;
        // #10;

        // v0_in = 32'h77777777;
        // v1_in = 32'h88888888;
        // k0 = 32'h99999999;
        // k1 = 32'haaaaaaaa;
        // k2 = 32'hbbbbbbbb;
        // k3 = 32'hcccccccc;
        // #10;

        // v0_in = 32'hffffffff;
        // v1_in = 32'h00000000;
        // k0 = 32'h12345678;
        // k1 = 32'h87654321;
        // k2 = 32'haaaaaaaa;
        // k3 = 32'h55555555;
        // #10;

        // v0_in = 32'h00112233;
        // v1_in = 32'h44556677;
        // k0 = 32'hfedcba98;
        // k1 = 32'h76543210;
        // k2 = 32'h89abcdef;
        // k3 = 32'h01234567;
        // #10;

        // v0_in = 32'h77665544;
        // v1_in = 32'h33221100;
        // k0 = 32'h12345678;
        // k1 = 32'h9abcdef0;
        // k2 = 32'h0fedcba9;
        // k3 = 32'h76543210;
        // #10;
        
        // v0_in = 32'hdeadbeff;
        // v1_in = 32'hcafebabe;
        // k0 = 32'h55667788;
        // k1 = 32'h11223344;
        // k2 = 32'h99aabbcc;
        // k3 = 32'hddeeff00;
        #100;
    end
endmodule