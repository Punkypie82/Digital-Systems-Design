//////////////////////////////////////////////////////////////////////////////////
// AXI4 Lite Slave Example
// By:
//        Ali Jahanian
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module axi4_lite_slave #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
    )
    (
        //Global Signals
        input                           ACLK,
        input                           ARESETN,

        ////Read Address Channel INPUTS
        input           [ADDRESS-1:0]   S_ARADDR,
        input                           S_ARVALID,
        //Read Data Channel INPUTS
        input                           S_RREADY,
        //Write Address Channel INPUTS
        /* verilator lint_off UNUSED */
        input           [ADDRESS-1:0]   S_AWADDR,
        input                           S_AWVALID,
        //Write Data  Channel INPUTS
        input          [DATA_WIDTH-1:0] S_WDATA,
        input          [3:0]            S_WSTRB,
        input                           S_WVALID,
        //Write Response Channel INPUTS
        input                           S_BREADY,	

        //Read Address Channel OUTPUTS
        output                     S_ARREADY,
        //Read Data Channel OUTPUTS
        output     [DATA_WIDTH-1:0]S_RDATA,
        output          [1:0]      S_RRESP,
        output                     S_RVALID,
        //Write Address Channel OUTPUTS
        output                     S_AWREADY,
        output                     S_WREADY,
        //Write Response Channel OUTPUTS
        output          [1:0]      S_BRESP,
        output                     S_BVALID
    );

    localparam REG_NUM = 32;
    localparam IDLE          = 0;
    localparam WRITE_CHANNEL = 1;
    localparam WRESP_CHANNEL = 2;
    localparam RADDR_CHANNEL = 3;
    localparam RDATA_CHANNEL = 4;
   
    reg  [DATA_WIDTH-1 : 0] register [0 : REG_NUM-1];
    reg  [ADDRESS-1 : 0]    read_addr;
    wire [ADDRESS-1 : 0]    S_ARADDR_T;
    wire [ADDRESS-1 : 0]    S_AWADDR_T;
    wire write_addr;
    wire write_data;
    reg  [2:0] state , next_state;
    
    // Address Read
    assign S_ARREADY = (state == RADDR_CHANNEL) ? 1 : 0;
    // Read
    assign S_RVALID = (state == RDATA_CHANNEL) ? 1 : 0;
    assign S_RDATA  = (state == RDATA_CHANNEL) ? register[read_addr] : 0;
    assign S_RRESP  = (state == RDATA_CHANNEL) ? 2'b00 : 0;
    // Address Write
    assign S_AWREADY = (state == WRITE_CHANNEL) ? 1 : 0;
    // Write
    assign S_WREADY = (state == WRITE_CHANNEL) ? 1 : 0;
    assign write_addr = S_AWVALID && S_AWREADY;
    assign write_data = S_WREADY &&S_WVALID;
    // Responce
    assign S_BVALID = (state == WRESP_CHANNEL) ? 1 : 0;
    assign S_BRESP  = (state == WRESP_CHANNEL )? 0:0;

    assign S_ARADDR_T = S_ARADDR[ADDRESS-1 : 2];
    assign S_AWADDR_T = S_AWADDR[ADDRESS-1 : 2];
    integer i;
    
    wire [783:0] fcn_input;
    wire [DATA_WIDTH-1 : 0] fcn_start, fcn_result, fcn_done;
    assign fcn_input = {register[0], register[1], register[2], register[3], register[4],
                        register[5], register[6], register[7], register[8], register[9],
                        register[10], register[11], register[12], register[13], register[14],
                        register[15], register[16], register[17], register[18], register[19],
                        register[20], register[21], register[22], register[23], register[24]};
    assign fcn_start = register[25];
    
    FCN uut(
        .clk(ACLK),
        .A(fcn_input),
        .start(fcn_start),
        .B(fcn_result),
        .done(fcn_done)
    );

    always @(posedge ACLK) begin
        // Reset the register array
        if (~ARESETN) begin
            for (i = 0; i < 32; i=i+1) begin
                register[i] <= 32'b0;
            end
            state <= IDLE;
        end
        else begin
            state <= next_state;
            if (state == WRITE_CHANNEL) begin
                register[S_AWADDR_T] <= S_WDATA;
            end
            else if (state == RADDR_CHANNEL) begin
                read_addr <= S_ARADDR_T;
                register[26] <= fcn_result;
                register[27] <= fcn_done;
            end
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
        IDLE : begin
            if (S_AWVALID) begin
                next_state = WRITE_CHANNEL;
            end 
            else if (S_ARVALID) begin
                next_state = RADDR_CHANNEL;
            end 
            else begin
                next_state = IDLE;
            end
        end
        RADDR_CHANNEL  : if (S_ARVALID && S_ARREADY ) next_state = RDATA_CHANNEL;
        RDATA_CHANNEL  : if (S_RVALID  && S_RREADY  ) next_state = IDLE;
        WRITE_CHANNEL  : if (write_addr &&write_data) next_state = WRESP_CHANNEL;
        WRESP_CHANNEL  : if (S_BVALID  && S_BREADY  ) next_state = IDLE;
        default        : next_state = IDLE;
        endcase
end
endmodule
