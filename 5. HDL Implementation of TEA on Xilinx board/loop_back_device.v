`timescale 1ns / 1ps
module loop_back_device(
		input rst, 			
		input clk, 	    
		output reg tx_start, 	
		output reg [7:0] tx_data, 		 
		input [7:0] rx_data, 	
		input rx_ready,  
		input tx_ready,  
	
	
		//------------------------------------------------
		// test vector signals should be configured 
		// corresponding with the design
		// Should be updated
		//------------------------------------------------
		output cut_clk,
		output cut_nrst,
		output [31:0] cut_v0_in, cut_v1_in,
		output [31:0] cut_k0, cut_k1, cut_k2, cut_k3,
		input  [31:0] cut_v0_out, cut_v1_out
	);

	//----------------------------------------------------------------
	// Number of input and output bits: 
	// Should be updated
	//----------------------------------------------------------------
	parameter InputSize  = 194; // number of input bits
	parameter OutputSize = 64;  // number of output bits
	//----------------------------------------------------------------
	
	
	parameter CHAR0 = 8'b00110000;
	parameter CHAR1 = 8'b00110001;
	
	parameter wait_for_data = 0;
    parameter wait_one_cycle = 1;
    parameter wait_after_input = 2;
    parameter wait_for_output = 3;
    parameter wait_after_output = 4;
    parameter send_output = 5;
    parameter send_equal = 6;
    parameter send_sharp = 7;	
 
	integer state;
	reg [7:0] input_reg [0:255];
    wire [7:0] output_reg [0:255];
	integer icntr, ocntr;
	function c2s(input [7:0] x); 
	begin
		if (x == CHAR0)
			c2s = 1'b0;
		else
			c2s = 1'b1;
  end
	endfunction
  
	function [7:0] s2c(input x); 
	begin
		if (x == 1'b0)
			s2c = CHAR0;
		else
			s2c = CHAR1;
	end
  endfunction

	always @(posedge clk)
	begin
		if (rst) 
    begin
			tx_data = 0;
			tx_start = 0;
			state = wait_for_data;
			icntr = 0;
			ocntr = 0;
    end
    else
    begin
      tx_start = 0;
      case (state)
      wait_for_data :
        if (rx_ready)
        begin
          tx_start = 1'b1;
          tx_data = rx_data;
          input_reg[icntr] = rx_data;
          if (icntr == (InputSize-1))
          begin
            icntr = 0;
            state = wait_after_input;
          end
          else
          begin
            icntr = icntr + 1;
            state = wait_one_cycle;
          end		
        end
      wait_one_cycle:
        state = wait_for_data;
      wait_after_input:
        if (!tx_ready)
        state = send_equal;
      send_equal:
        if (tx_ready)
        begin
          tx_start = 1'b1;
          tx_data = 8'b00111101; //0x3D (=)
          state = wait_for_output;
        end
        else
        begin
          state <= send_equal;
        end
      wait_for_output:
        if (tx_ready == 0)
          state = send_output;
      send_output:
        if (tx_ready)
        begin
          tx_start = 1'b1;
          tx_data = output_reg[OutputSize - ocntr - 1];
          if (ocntr == (OutputSize-1))
          begin
            ocntr = 0;
            state = wait_after_output;
          end
          else
          begin
            ocntr = ocntr + 1;
            state = wait_for_output;
          end
        end
        else
          state = send_output;
      wait_after_output:
        state = send_sharp;
      send_sharp:
        if (tx_ready)
        begin
          tx_start = 1'b1;
          tx_data = 8'b00100011; //0x23 (#)
          state = wait_for_data;
        end
        else
          state = send_sharp;
      default:
      begin  
        tx_start = 1'b0;
        tx_data = rx_data;
        state = wait_for_data;
      end
      endcase
		end
	end

	//------------------------------------------
	// Inteface with CUT: Should be updated
	// Should be updated
	//------------------------------------------

	// convert input characters to bits
	assign cut_clk  	 = c2s(input_reg[0]);
	assign cut_nrst	 	 = c2s(input_reg[1]);
	
	assign cut_v0_in[31] = c2s(input_reg[2]);
	assign cut_v0_in[30] = c2s(input_reg[3]);
	assign cut_v0_in[29] = c2s(input_reg[4]);
	assign cut_v0_in[28] = c2s(input_reg[5]);
	assign cut_v0_in[27] = c2s(input_reg[6]);
	assign cut_v0_in[26] = c2s(input_reg[7]);
	assign cut_v0_in[25] = c2s(input_reg[8]);
	assign cut_v0_in[24] = c2s(input_reg[9]);
	assign cut_v0_in[23] = c2s(input_reg[10]);
	assign cut_v0_in[22] = c2s(input_reg[11]);
	assign cut_v0_in[21] = c2s(input_reg[12]);
	assign cut_v0_in[20] = c2s(input_reg[13]);
	assign cut_v0_in[19] = c2s(input_reg[14]);
	assign cut_v0_in[18] = c2s(input_reg[15]);
	assign cut_v0_in[17] = c2s(input_reg[16]);
	assign cut_v0_in[16] = c2s(input_reg[17]);
	assign cut_v0_in[15] = c2s(input_reg[18]);
	assign cut_v0_in[14] = c2s(input_reg[19]);
	assign cut_v0_in[13] = c2s(input_reg[20]);
	assign cut_v0_in[12] = c2s(input_reg[21]);
	assign cut_v0_in[11] = c2s(input_reg[22]);
	assign cut_v0_in[10] = c2s(input_reg[23]);
	assign cut_v0_in[9]  = c2s(input_reg[24]);
	assign cut_v0_in[8]  = c2s(input_reg[25]);
	assign cut_v0_in[7]  = c2s(input_reg[26]);
	assign cut_v0_in[6]  = c2s(input_reg[27]);
	assign cut_v0_in[5]  = c2s(input_reg[28]);
	assign cut_v0_in[4]  = c2s(input_reg[29]);
	assign cut_v0_in[3]  = c2s(input_reg[30]);
	assign cut_v0_in[2]  = c2s(input_reg[31]);
	assign cut_v0_in[1]  = c2s(input_reg[32]);
	assign cut_v0_in[0]  = c2s(input_reg[33]);
	
	assign cut_v1_in[31] = c2s(input_reg[34]);
    assign cut_v1_in[30] = c2s(input_reg[35]);
    assign cut_v1_in[29] = c2s(input_reg[36]);
    assign cut_v1_in[28] = c2s(input_reg[37]);
    assign cut_v1_in[27] = c2s(input_reg[38]);
    assign cut_v1_in[26] = c2s(input_reg[39]);
    assign cut_v1_in[25] = c2s(input_reg[40]);
    assign cut_v1_in[24] = c2s(input_reg[41]);
    assign cut_v1_in[23] = c2s(input_reg[42]);
    assign cut_v1_in[22] = c2s(input_reg[43]);
    assign cut_v1_in[21] = c2s(input_reg[44]);
    assign cut_v1_in[20] = c2s(input_reg[45]);
    assign cut_v1_in[19] = c2s(input_reg[46]);
    assign cut_v1_in[18] = c2s(input_reg[47]);
    assign cut_v1_in[17] = c2s(input_reg[48]);
    assign cut_v1_in[16] = c2s(input_reg[49]);
    assign cut_v1_in[15] = c2s(input_reg[50]);
    assign cut_v1_in[14] = c2s(input_reg[51]);
    assign cut_v1_in[13] = c2s(input_reg[52]);
    assign cut_v1_in[12] = c2s(input_reg[53]);
    assign cut_v1_in[11] = c2s(input_reg[54]);
    assign cut_v1_in[10] = c2s(input_reg[55]);
    assign cut_v1_in[9]  = c2s(input_reg[56]);
    assign cut_v1_in[8]  = c2s(input_reg[57]);
    assign cut_v1_in[7]  = c2s(input_reg[58]);
    assign cut_v1_in[6]  = c2s(input_reg[59]);
    assign cut_v1_in[5]  = c2s(input_reg[60]);
    assign cut_v1_in[4]  = c2s(input_reg[61]);
    assign cut_v1_in[3]  = c2s(input_reg[62]);
    assign cut_v1_in[2]  = c2s(input_reg[63]);
    assign cut_v1_in[1]  = c2s(input_reg[64]);
    assign cut_v1_in[0]  = c2s(input_reg[65]);

    assign cut_k0[31]    = c2s(input_reg[66]);
    assign cut_k0[30]    = c2s(input_reg[67]);
    assign cut_k0[29]    = c2s(input_reg[68]);
    assign cut_k0[28]    = c2s(input_reg[69]);
    assign cut_k0[27]    = c2s(input_reg[70]);
    assign cut_k0[26]    = c2s(input_reg[71]);
    assign cut_k0[25]    = c2s(input_reg[72]);
    assign cut_k0[24]    = c2s(input_reg[73]);
    assign cut_k0[23]    = c2s(input_reg[74]);
    assign cut_k0[22]    = c2s(input_reg[75]);
    assign cut_k0[21]    = c2s(input_reg[76]);
    assign cut_k0[20]    = c2s(input_reg[77]);
    assign cut_k0[19]    = c2s(input_reg[78]);
    assign cut_k0[18]    = c2s(input_reg[79]);
    assign cut_k0[17]    = c2s(input_reg[80]);
    assign cut_k0[16]    = c2s(input_reg[81]);
    assign cut_k0[15]    = c2s(input_reg[82]);
    assign cut_k0[14]    = c2s(input_reg[83]);
    assign cut_k0[13]    = c2s(input_reg[84]);
    assign cut_k0[12]    = c2s(input_reg[85]);
    assign cut_k0[11]    = c2s(input_reg[86]);
    assign cut_k0[10]    = c2s(input_reg[87]);
    assign cut_k0[9]     = c2s(input_reg[88]);
    assign cut_k0[8]     = c2s(input_reg[89]);
    assign cut_k0[7]     = c2s(input_reg[90]);
    assign cut_k0[6]     = c2s(input_reg[91]);
    assign cut_k0[5]     = c2s(input_reg[92]);
    assign cut_k0[4]     = c2s(input_reg[93]);
    assign cut_k0[3]     = c2s(input_reg[94]);
    assign cut_k0[2]     = c2s(input_reg[95]);
    assign cut_k0[1]     = c2s(input_reg[96]);
    assign cut_k0[0]     = c2s(input_reg[97]);

    assign cut_k1[31]    = c2s(input_reg[98]);
    assign cut_k1[30]    = c2s(input_reg[99]);
    assign cut_k1[29]    = c2s(input_reg[100]);
    assign cut_k1[28]    = c2s(input_reg[101]);
    assign cut_k1[27]    = c2s(input_reg[102]);
    assign cut_k1[26]    = c2s(input_reg[103]);
    assign cut_k1[25]    = c2s(input_reg[104]);
    assign cut_k1[24]    = c2s(input_reg[105]);
    assign cut_k1[23]    = c2s(input_reg[106]);
    assign cut_k1[22]    = c2s(input_reg[107]);
    assign cut_k1[21]    = c2s(input_reg[108]);
    assign cut_k1[20]    = c2s(input_reg[109]);
    assign cut_k1[19]    = c2s(input_reg[110]);
    assign cut_k1[18]    = c2s(input_reg[111]);
    assign cut_k1[17]    = c2s(input_reg[112]);
    assign cut_k1[16]    = c2s(input_reg[113]);
    assign cut_k1[15]    = c2s(input_reg[114]);
    assign cut_k1[14]    = c2s(input_reg[115]);
    assign cut_k1[13]    = c2s(input_reg[116]);
    assign cut_k1[12]    = c2s(input_reg[117]);
    assign cut_k1[11]    = c2s(input_reg[118]);
    assign cut_k1[10]    = c2s(input_reg[119]);
    assign cut_k1[9]     = c2s(input_reg[120]);
    assign cut_k1[8]     = c2s(input_reg[121]);
    assign cut_k1[7]     = c2s(input_reg[122]);
    assign cut_k1[6]     = c2s(input_reg[123]);
    assign cut_k1[5]     = c2s(input_reg[124]);
    assign cut_k1[4]     = c2s(input_reg[125]);
    assign cut_k1[3]     = c2s(input_reg[126]);
    assign cut_k1[2]     = c2s(input_reg[127]);
    assign cut_k1[1]     = c2s(input_reg[128]);
    assign cut_k1[0]     = c2s(input_reg[129]);

    assign cut_k2[31]    = c2s(input_reg[130]);
    assign cut_k2[30]    = c2s(input_reg[131]);
    assign cut_k2[29]    = c2s(input_reg[132]);
    assign cut_k2[28]    = c2s(input_reg[133]);
    assign cut_k2[27]    = c2s(input_reg[134]);
    assign cut_k2[26]    = c2s(input_reg[135]);
    assign cut_k2[25]    = c2s(input_reg[136]);
    assign cut_k2[24]    = c2s(input_reg[137]);
    assign cut_k2[23]    = c2s(input_reg[138]);
    assign cut_k2[22]    = c2s(input_reg[139]);
    assign cut_k2[21]    = c2s(input_reg[140]);
    assign cut_k2[20]    = c2s(input_reg[141]);
    assign cut_k2[19]    = c2s(input_reg[142]);
    assign cut_k2[18]    = c2s(input_reg[143]);
    assign cut_k2[17]    = c2s(input_reg[144]);
    assign cut_k2[16]    = c2s(input_reg[145]);
    assign cut_k2[15]    = c2s(input_reg[146]);
    assign cut_k2[14]    = c2s(input_reg[147]);
    assign cut_k2[13]    = c2s(input_reg[148]);
    assign cut_k2[12]    = c2s(input_reg[149]);
    assign cut_k2[11]    = c2s(input_reg[150]);
    assign cut_k2[10]    = c2s(input_reg[151]);
    assign cut_k2[9]     = c2s(input_reg[152]);
    assign cut_k2[8]     = c2s(input_reg[153]);
    assign cut_k2[7]     = c2s(input_reg[154]);
    assign cut_k2[6]     = c2s(input_reg[155]);
    assign cut_k2[5]     = c2s(input_reg[156]);
    assign cut_k2[4]     = c2s(input_reg[157]);
    assign cut_k2[3]     = c2s(input_reg[158]);
    assign cut_k2[2]     = c2s(input_reg[159]);
    assign cut_k2[1]     = c2s(input_reg[160]);
    assign cut_k2[0]     = c2s(input_reg[161]);
    
    assign cut_k3[31]    = c2s(input_reg[162]);
    assign cut_k3[30]    = c2s(input_reg[163]);
    assign cut_k3[29]    = c2s(input_reg[164]);
    assign cut_k3[28]    = c2s(input_reg[165]);
    assign cut_k3[27]    = c2s(input_reg[166]);
    assign cut_k3[26]    = c2s(input_reg[167]);
    assign cut_k3[25]    = c2s(input_reg[168]);
    assign cut_k3[24]    = c2s(input_reg[169]);
    assign cut_k3[23]    = c2s(input_reg[170]);
    assign cut_k3[22]    = c2s(input_reg[171]);
    assign cut_k3[21]    = c2s(input_reg[172]);
    assign cut_k3[20]    = c2s(input_reg[173]);
    assign cut_k3[19]    = c2s(input_reg[174]);
    assign cut_k3[18]    = c2s(input_reg[175]);
    assign cut_k3[17]    = c2s(input_reg[176]);
    assign cut_k3[16]    = c2s(input_reg[177]);
    assign cut_k3[15]    = c2s(input_reg[178]);
    assign cut_k3[14]    = c2s(input_reg[179]);
    assign cut_k3[13]    = c2s(input_reg[180]);
    assign cut_k3[12]    = c2s(input_reg[181]);
    assign cut_k3[11]    = c2s(input_reg[182]);
    assign cut_k3[10]    = c2s(input_reg[183]);
    assign cut_k3[9]     = c2s(input_reg[184]);
    assign cut_k3[8]     = c2s(input_reg[185]);
    assign cut_k3[7]     = c2s(input_reg[186]);
    assign cut_k3[6]     = c2s(input_reg[187]);
    assign cut_k3[5]     = c2s(input_reg[188]);
    assign cut_k3[4]     = c2s(input_reg[189]);
    assign cut_k3[3]     = c2s(input_reg[190]);
    assign cut_k3[2]     = c2s(input_reg[191]);
    assign cut_k3[1]     = c2s(input_reg[192]);
    assign cut_k3[0]     = c2s(input_reg[193]);

	// convert output bits to character
	assign output_reg[63] = s2c(cut_v0_out[31]);
    assign output_reg[62] = s2c(cut_v0_out[30]);
    assign output_reg[61] = s2c(cut_v0_out[29]);
    assign output_reg[60] = s2c(cut_v0_out[28]);
    assign output_reg[59] = s2c(cut_v0_out[27]);
    assign output_reg[58] = s2c(cut_v0_out[26]);
    assign output_reg[57] = s2c(cut_v0_out[25]);
    assign output_reg[56] = s2c(cut_v0_out[24]);
    assign output_reg[55] = s2c(cut_v0_out[23]);
    assign output_reg[54] = s2c(cut_v0_out[22]);
    assign output_reg[53] = s2c(cut_v0_out[21]);
    assign output_reg[52] = s2c(cut_v0_out[20]);
    assign output_reg[51] = s2c(cut_v0_out[19]);
    assign output_reg[50] = s2c(cut_v0_out[18]);
    assign output_reg[49] = s2c(cut_v0_out[17]);
    assign output_reg[48] = s2c(cut_v0_out[16]);
    assign output_reg[47] = s2c(cut_v0_out[15]);
    assign output_reg[46] = s2c(cut_v0_out[14]);
    assign output_reg[45] = s2c(cut_v0_out[13]);
    assign output_reg[44] = s2c(cut_v0_out[12]);
    assign output_reg[43] = s2c(cut_v0_out[11]);
    assign output_reg[42] = s2c(cut_v0_out[10]);
    assign output_reg[41] = s2c(cut_v0_out[9]);
    assign output_reg[40] = s2c(cut_v0_out[8]);
    assign output_reg[39] = s2c(cut_v0_out[7]);
    assign output_reg[38] = s2c(cut_v0_out[6]);
    assign output_reg[37] = s2c(cut_v0_out[5]);
    assign output_reg[36] = s2c(cut_v0_out[4]);
    assign output_reg[35] = s2c(cut_v0_out[3]);
    assign output_reg[34] = s2c(cut_v0_out[2]);
    assign output_reg[33] = s2c(cut_v0_out[1]);
    assign output_reg[32] = s2c(cut_v0_out[0]);
	
	assign output_reg[31] = s2c(cut_v1_out[31]);
	assign output_reg[30] = s2c(cut_v1_out[30]);
	assign output_reg[29] = s2c(cut_v1_out[29]);
	assign output_reg[28] = s2c(cut_v1_out[28]);
	assign output_reg[27] = s2c(cut_v1_out[27]);
	assign output_reg[26] = s2c(cut_v1_out[26]);
	assign output_reg[25] = s2c(cut_v1_out[25]);
	assign output_reg[24] = s2c(cut_v1_out[24]);
	assign output_reg[23] = s2c(cut_v1_out[23]);
	assign output_reg[22] = s2c(cut_v1_out[22]);
	assign output_reg[21] = s2c(cut_v1_out[21]);
	assign output_reg[20] = s2c(cut_v1_out[20]);
	assign output_reg[19] = s2c(cut_v1_out[19]);
	assign output_reg[18] = s2c(cut_v1_out[18]);
	assign output_reg[17] = s2c(cut_v1_out[17]);
	assign output_reg[16] = s2c(cut_v1_out[16]);
	assign output_reg[15] = s2c(cut_v1_out[15]);
	assign output_reg[14] = s2c(cut_v1_out[14]);
	assign output_reg[13] = s2c(cut_v1_out[13]);
	assign output_reg[12] = s2c(cut_v1_out[12]);
	assign output_reg[11] = s2c(cut_v1_out[11]);
	assign output_reg[10] = s2c(cut_v1_out[10]);
	assign output_reg[9]  = s2c(cut_v1_out[9]);
	assign output_reg[8]  = s2c(cut_v1_out[8]);
	assign output_reg[7]  = s2c(cut_v1_out[7]);
	assign output_reg[6]  = s2c(cut_v1_out[6]);
	assign output_reg[5]  = s2c(cut_v1_out[5]);
	assign output_reg[4]  = s2c(cut_v1_out[4]);
	assign output_reg[3]  = s2c(cut_v1_out[3]);
	assign output_reg[2]  = s2c(cut_v1_out[2]);
	assign output_reg[1]  = s2c(cut_v1_out[1]);
	assign output_reg[0]  = s2c(cut_v1_out[0]);
endmodule
