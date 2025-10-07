`timescale 1ns / 1ps

/// Remote FPGA Tester Designed by Ali Jahanian

module SerialRFT
    #(parameter int unsigned DIVIDER = 0) 
    (
      input  mclk, 
      input  rst, 
      input  rx, 
      output tx
    );

    wire tx_start, rx_ready, tx_ready; 
    wire [7:0] data_lb_uart, data_uart_lb;

     //************************************
     //  Cuitsuit Under Test Signals
     //************************************
    wire cut_clk;
    wire cut_nrst;
    wire [31:0] cut_v0_in, cut_v1_in;
    wire [31:0] cut_k0, cut_k1, cut_k2, cut_k3;
    wire [31:0] cut_v0_out, cut_v1_out;
  
  uart UART (
    .clk(mclk), 
    .rst(rst), 
    .start(tx_start), 
    .din(data_lb_uart), 
    .dout(data_uart_lb), 
    .rx_done(rx_ready), 
    .tx_rdy(tx_ready), 
    .rx(rx), 
    .tx(tx)
  );

  //------------------------------------------
  // Port Mapping of  loop_back_device
  // Should be updated
  //------------------------------------------
  loop_back_device LBD (
    .rst(rst), 
    .clk(mclk), 
    .tx_start(tx_start), 
    .tx_data(data_lb_uart), 
    .rx_data(data_uart_lb), 
    .rx_ready(rx_ready), 
    .tx_ready(tx_ready), 
    .cut_clk(cut_clk), 
    .cut_nrst(cut_nrst), 
    .cut_v0_in(cut_v0_in),
    .cut_v1_in(cut_v1_in),
    .cut_k0(cut_k0), 
    .cut_k1(cut_k1), 
    .cut_k2(cut_k2), 
    .cut_k3(cut_k3), 
    .cut_v0_out(cut_v0_out),
    .cut_v1_out(cut_v1_out)
  );
  
  //------------------------------------------
  // Port Mapping of  Circuit_Under_Test
  // Should be updated
  //------------------------------------------
  TEA CUT (
    .clk(cut_clk), 
    .nrst(cut_nrst), 
    .v0_in(cut_v0_in), 
    .v1_in(cut_v1_in), 
    .k0(cut_k0), 
    .k1(cut_k1), 
    .k2(cut_k2), 
    .k3(cut_k3), 
    .v0_out(cut_v0_out),
    .v1_out(cut_v1_out)
  );

endmodule