module mano_core(clk, rst);
  input clk, rst;

  //*********************
  // Control signals
  //*********************
  reg ar_ld, ar_clr;
  reg ac_ld, ac_clr, ac_inr;
  reg dr_ld, dr_clr, dr_inr;
  reg tr_ld, tr_clr;
  reg pc_ld, pc_clr, pc_inr;
  reg e_ld, e_clr;
  reg i_ld;
  reg ir_ld;
  reg sc_clr;
  reg wr, rd;
  reg hlt;
  reg [2:0] sc;
  reg [3:0] bus_sel;
  reg [3:0] alu_func;

  //***********************
  // Registers and busses
  //***********************
  wire [15:0] mem_out;
  reg  [15:0] abus, dr, ac, tr, ir;
  reg  [16:0] alu_out;
  reg  [11:0] pc = 0, ar;
  reg  [15:0] mem [31:0];
  reg  i, e = 0;
  
  //*********************
  // 4096x16 Memory
  //*********************
  always @(posedge clk)
  begin
    if (wr == 1)
      mem[ar[5:0]] = abus;
  end
  assign mem_out = mem[ar[5:0]];

  //*********************
  // Sequential Circuit
  //*********************
  always @(posedge clk)
  begin
    if (rst == 1) begin
      sc = 3'b000;
      hlt = 0;
    end
    else if (hlt != 1)
    begin
      if (sc_clr == 1) 
      begin
        sc = 0;
        i = 0;
      end
      else  
        sc = sc + 1;
      
      if (ir_ld == 1)
        i = abus[15];
        
      if (ac_clr == 1)
        ac = 0;
      else if (ac_ld == 1)  
        ac = alu_out[15:0];
      else if (ac_inr == 1)
        ac = ac + 1;

      if (ar_clr == 1)
        ar = 0;
      else if (ar_ld == 1)  
        ar = abus;

      if (dr_clr == 1)
        dr = 0;
      else if (dr_ld == 1)  
        dr = abus;
      else if (dr_inr == 1)
        dr = dr + 1;

      if (pc_clr == 1)
        pc = 0;
      else if (pc_ld == 1)  
        pc = abus;
      else if (pc_inr == 1)  
        pc = pc + 1;

      if (ir_ld == 1)
        ir = abus;

      if (e_clr == 1)
        e = 0;
      else if (e_ld == 1)
        e = alu_out[16];
    end
  end

  //*********************
  // BUS Select
  //*********************
  always @(*)
  begin
    case (bus_sel)
      3'b001: abus = ar;
      3'b010: abus = pc;
      3'b011: abus = dr;
      3'b100: abus = ac;
      3'b101: abus = ir;
      3'b110: abus = tr;
      default:abus = mem_out;
    endcase
  end
 
  //*********************
  // ALU Functions
  //*********************
  always @(*)
  begin
    case (alu_func)
      3'b000: alu_out = {e, dr};
      3'b001: alu_out = {e, dr & ac};
      3'b010: alu_out = dr + ac;
      3'b011: alu_out = {e, ~ac};
      3'b100: begin 
        alu_out = {ac[0], e, ac[15:1]};
      end
      3'b101: begin 
        alu_out = {ac, e};
      end
      3'b110: begin
        alu_out = {e, ~ac[15], ac[14:0]};
      end
      default:alu_out = {e, ac};
    endcase
  end

//***********************
// Combinational state machine
//***********************
  always @(*)
  begin
    ar_ld = 0;
    ar_clr = 0;
    ac_ld = 0;
    ac_clr = 0;
    ac_inr = 0;
    dr_ld = 0;
    dr_clr = 0;
    dr_inr = 0;
    tr_ld = 0;
    tr_clr = 0;
    pc_ld = 0;
    pc_clr = 0;
    pc_inr = 0;
    ir_ld = 0;
    sc_clr = 0;
    e_ld = 0;
    e_clr = 0;
    i_ld = 0;
    wr = 0;
    rd = 0;
    case (sc)
      3'b000: 
      begin 
        ar_ld = 1; 
        bus_sel = 3'b010;  //PC
      end
      3'b001: 
      begin 
        pc_inr = 1; 
        bus_sel = 3'b111;  //mem
        ir_ld = 1;
      end
      3'b010: 
      begin 
        bus_sel = 3'b101;  //IR
        ar_ld = 1;
        i_ld = 1;
      end
      3'b011: 
      begin 
        if(ir[14:12] == 3'b111)
        begin
          case (ir[11:0])
            12'b100000000000:
            begin
              ac_clr = 1;
              sc_clr = 1;
            end
            12'b010000000000:
            begin
              e_clr = 1;
              sc_clr = 1;
            end
            12'b001000000000:
            begin
              alu_func = 3'b011;
              ac_ld = 1;
              sc_clr = 1;
            end
            12'b000100000000:
            begin
              alu_func = 3'b100;
              ac_ld = 1;
              e_ld = 1;
            end
            12'b000010000000:
            begin
              alu_func = 3'b100;
              ac_ld = 1;
              e_ld = 1;
              sc_clr = 1;
            end
            12'b000001000000:
            begin
              alu_func = 3'b101;
              ac_ld = 1;
              e_ld = 1;
              sc_clr = 1;
            end
            12'b000000100000:
            begin
              ac_inr = 1;
              sc_clr = 1;
            end
            12'b000000010000:
            begin
              if (ac[15] == 0)
                pc_inr = 1;
              sc_clr = 1;
            end
            12'b000000001000:
            begin
              if (ac[15] == 1)
                pc_inr = 1;
              sc_clr = 1;
            end
            12'b000000000100:
            begin
              if (ac == 16'b0000000000000000)
                pc_inr = 1;
              sc_clr = 1;
            end
            12'b000000000010:
            begin
              if (e == 0)
                pc_inr = 1;
              sc_clr = 1;
            end
            12'b000000000001:
            begin
              hlt = 1;
            end
          endcase
        end
        else
        begin
          if (i == 1)
          begin
            ar_ld = 1;
            bus_sel = 3'b111;
          end
        end
      end
      3'b100: 
      begin
        case (ir[14:12])
          3'b111: // For CME
          begin
            alu_func = 3'b110;
            ac_ld = 1;
          end
          default:
          begin
            dr_ld = 1;
            bus_sel = 3'b111;
          end
        endcase
      end
      3'b101:
      begin
        case (ir[14:12])
          3'b111: // For CME
          begin
            alu_func = 3'b101;
            ac_ld = 1;
            e_ld = 1;
            sc_clr = 1;
          end
          3'b000:
          begin
            alu_func = 3'b001;
            ac_ld = 1;
            sc_clr = 1;
          end
          3'b001:
          begin
            alu_func = 3'b010;
            ac_ld = 1;
            e_ld = 1;
            sc_clr = 1;
          end
          3'b010:
          begin
            alu_func = 3'b000;
            ac_ld = 1;
            sc_clr = 1;
          end
          3'b011:
          begin
            bus_sel = 3'b100;
            wr = 1;
            sc_clr = 1;
          end
          3'b100:
          begin
            bus_sel = 3'b001;
            pc_ld = 1;
            sc_clr = 1;
          end
          3'b101:
          begin
            bus_sel = 3'b010;
            wr = 1;
          end
          3'b110:
          begin
            dr_inr = 1;
          end
        endcase
      end
      3'b110:
      begin
        case (ir[14:12])
          3'b101:
          begin
            bus_sel = 3'b001;
            pc_ld = 1;
          end
          3'b110:
          begin
            bus_sel = 3'b011;
            wr = 1;
          end
        endcase
      end
      3'b111:
      begin
        case (ir[14:12])
          3'b101:
          begin
            pc_inr = 1;
            sc_clr = 1;
          end
          3'b110:
          begin
            if (dr == 16'b0000000000000000)
            begin
              pc_inr = 1;
              sc_clr = 0;
            end
          end
        endcase
      end
    endcase
  end
endmodule
