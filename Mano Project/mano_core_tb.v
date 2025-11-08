module mano_core_tb;
  reg clk_t = 0, rst_t = 1;
  integer i;

  mano_core U1 (clk_t, rst_t);

  initial begin
    // Test Case 1
    U1.mem[0] = 16'h2006; // LDA
    U1.mem[1] = 16'h7020; // INC
    U1.mem[2] = 16'h3007; // STA
    U1.mem[3] = 16'h0006; // AND
    U1.mem[4] = 16'h1007; // ADD
    U1.mem[5] = 16'h4000; // BUN
    U1.mem[6] = 16'h0020;
    U1.mem[7] = 16'h0000;

    // Test Case 2
    // U1.mem[0] = 16'h7800; // CLA
    // U1.mem[1] = 16'h7400; // CLE
    // U1.mem[2] = 16'h7200; // CMA
    // U1.mem[3] = 16'h7100; // CME
    // U1.mem[4] = 16'h7080; // CIR
    // U1.mem[5] = 16'h7040; // CIL
    // U1.mem[6] = 16'h7020; // INC
    // U1.mem[7] = 16'h7010; // SPA
    // U1.mem[9] = 16'h7008; // SNA
    // U1.mem[8] = 16'h7004; // SZA
    // U1.mem[10] = 16'h7002; // SZE

    // Test Case 3
    // U1.mem[0] = 16'h2010; // LDA 0x0010
    // U1.mem[1] = 16'h1012; // ADD 0x0012
    // U1.mem[2] = 16'h3013; // STA 0x0013
    // U1.mem[3] = 16'h7200; // ~AC
    // U1.mem[4] = 16'h7008; // SNA skip if neg
    // U1.mem[5] = 16'h7800; // clear ac 
    // U1.mem[6] = 16'h7100; // ~E
    // U1.mem[7] = 16'h7080; // Circular right
    // U1.mem[8] = 16'h7040; // Circular left
    // U1.mem[9] = 16'h7020; // Inc AC
    // U1.mem[10] = 16'h7400; // clear E
    // U1.mem[11] = 16'h7002; // SZE
    // U1.mem[12] = 16'h7800; // clear ac
    // U1.mem[13] = 16'h7020; // inc AC

    // ****** Memory inst Test bench *******
    // U1.mem[0] = 16'h2010;  // LDA 0x0010
    // U1.mem[1] = 16'h1011;  // ADD 0x0011
    // U1.mem[2] = 16'h3015; // STA to mem[21]
    // U1.mem[3] = 16'h4006; // Branch to 6
    // U1.mem[4] = 16'h2010;  // LDA 0x0010
    // U1.mem[5] = 16'h3016; // STA TO MEM[22]
    // U1.mem[6] = 16'h2010;  // LDA 0x00010 = 9
    // U1.mem[7] = 16'h8013; // AND 0013 = C
    // U1.mem[8] = 16'h3017;  // STA mem[23] = 8

    // U1.mem[16] = 16'h0009;  // Value at address 0x0010
    // U1.mem[17] = 16'h000C;  // Value at address 0x0011
    // U1.mem[18] = 16'hFFFD; // -3 Value at address 0x0012
    // U1.mem[19] = 16'h0011; // address of mem [17] 0x0013
  end

  initial begin
    rst_t = 1;
    #30 rst_t = 0; 
  end

  initial begin
    for (i = 0; i < 1000; i = i + 1)
      #5 clk_t = !clk_t;
  end
endmodule
