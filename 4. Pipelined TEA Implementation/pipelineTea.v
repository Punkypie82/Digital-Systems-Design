module TEA(
    input clk,
    input nrst,
    input [31:0] v0_in, v1_in,
    input [31:0] k0, k1, k2, k3,
    output reg [31:0] v0_out, v1_out
);
    localparam DELTA_CONST = 32'h9E3779B9;
    localparam CYCLE_NUM   = 32;

    reg [31:0]  v0_pipeline_p  [0:CYCLE_NUM - 1];
    reg [31:0]  v1_pipeline_p  [0:CYCLE_NUM - 1];
    reg [31:0]  sum_pipeline   [0:CYCLE_NUM - 1];
    reg [127:0] key_pipeline   [0:CYCLE_NUM - 1];
    
    wire [31:0] v0_pipeline_c  [0:CYCLE_NUM - 1];
    wire [31:0] v1_pipeline_c  [0:CYCLE_NUM - 1];

    genvar j;
    generate
    for (j = 0; j < CYCLE_NUM; j = j + 1) begin : stages
        singleTeaStage stage (
            .v0_p(v0_pipeline_p[j]), .v1_p(v1_pipeline_p[j]), .sum(sum_pipeline[j]),  // Corrected line
            .k0(key_pipeline[j][31:0]), .k1(key_pipeline[j][63:32]),  .k2(key_pipeline[j][95:64]),  .k3(key_pipeline[j][127:96]), 
            .v0_c(v0_pipeline_c[j]), .v1_c(v1_pipeline_c[j])
        );
    end
    endgenerate

    integer i;
    always @(posedge clk) begin
        if (!nrst) begin
            v0_out <= 0;
            v1_out <= 0;
 
            for (i = 0; i <= CYCLE_NUM; i = i + 1) begin
                v0_pipeline_p[i]  <= 0;
                v1_pipeline_p[i]  <= 0;
                sum_pipeline[i]   <= 0;
                key_pipeline[i]   <= 0;
            end
        end 
        else begin
            v0_pipeline_p[0]  <= v0_in;
            v1_pipeline_p[0]  <= v1_in;
            sum_pipeline[0]   <= DELTA_CONST;
            key_pipeline[0]   <= {k3, k2, k1, k0};
            
            for (i = 0; i < CYCLE_NUM; i = i + 1) begin
                sum_pipeline[i + 1]   <= sum_pipeline[i] + DELTA_CONST;
                v0_pipeline_p[i + 1]  <= v0_pipeline_c[i];
                v1_pipeline_p[i + 1]  <= v1_pipeline_c[i];
                key_pipeline[i + 1]   <= key_pipeline[i];
            end

            v0_out <= v0_pipeline_c[CYCLE_NUM - 1];
            v1_out <= v1_pipeline_c[CYCLE_NUM - 1];
        end
    end
endmodule

module singleTeaStage (
    input [31:0] v0_p, v1_p, sum,
    input [31:0] k0, k1, k2, k3,
    output reg [31:0] v0_c, v1_c
);
    always @(v0_p, v1_p) begin
        v0_c = v0_p + (((v1_p << 4) + k0) ^ (v1_p + sum) ^ ((v1_p >> 5) + k1));
        v1_c = v1_p + (((v0_c << 4) + k2) ^ (v0_c + sum) ^ ((v0_c >> 5) + k3));
    end
endmodule


/////////////////////////////////////



module TEA(
    input clk,
    input nrst,
    input [31:0] v0_in, v1_in,
    input [31:0] k0, k1, k2, k3,
    output reg [31:0] v0_out, v1_out
);
    localparam DELTA_CONST = 32'h9E3779B9;
    localparam CYCLE_NUM   = 32;

    reg [31:0]  v0_pipeline_p  [0:CYCLE_NUM - 1];
    reg [31:0]  v1_pipeline_p  [0:CYCLE_NUM - 1];
    reg [31:0]  sum_pipeline   [0:CYCLE_NUM - 1];
    reg [127:0] key_pipeline   [0:CYCLE_NUM - 1];
    
    wire [31:0] v0_pipeline_c  [0:CYCLE_NUM - 1];
    wire [31:0] v1_pipeline_c  [0:CYCLE_NUM - 1];
    
    reg [5:0] cnt;

    genvar j;
    generate
    for (j = 0; j < CYCLE_NUM; j = j + 1) begin : stages
        singleTeaStage stage (
            .v0_p(v0_pipeline_p[j]), .v1_p(v1_pipeline_p[j]), .sum(sum_pipeline[j]),  // Corrected line
            .k0(key_pipeline[j][31:0]), .k1(key_pipeline[j][63:32]),  .k2(key_pipeline[j][95:64]),  .k3(key_pipeline[j][127:96]), 
            .v0_c(v0_pipeline_c[j]), .v1_c(v1_pipeline_c[j])
        );
    end
    endgenerate

    integer i;
    always @(posedge clk) begin
        if (!nrst) begin
            v0_out <= 0;
            v1_out <= 0;
 
            for (i = 0; i <= CYCLE_NUM; i = i + 1) begin
                v0_pipeline_p[i]  <= 0;
                v1_pipeline_p[i]  <= 0;
                sum_pipeline[i]   <= 0;
                key_pipeline[i]   <= 0;
            end
            
            cnt <= 0;
        end 
        else begin
            v0_pipeline_p[0]  <= v0_in;
            v1_pipeline_p[0]  <= v1_in;
            sum_pipeline[0]   <= DELTA_CONST;
            key_pipeline[0]   <= {k3, k2, k1, k0};
            
            for (i = 0; i < CYCLE_NUM; i = i + 1) begin
                sum_pipeline[i + 1]   <= sum_pipeline[i] + DELTA_CONST;
                v0_pipeline_p[i + 1]  <= v0_pipeline_c[i];
                v1_pipeline_p[i + 1]  <= v1_pipeline_c[i];
                key_pipeline[i + 1]   <= key_pipeline[i];
            end
            
            if (cnt < CYCLE_NUM) 
                cnt <= cnt + 1;
            else begin
                v0_out <= v0_pipeline_c[CYCLE_NUM - 1];
                v1_out <= v1_pipeline_c[CYCLE_NUM - 1];
            end
        end
    end
endmodule

module singleTeaStage (
    input [31:0] v0_p, v1_p, sum,
    input [31:0] k0, k1, k2, k3,
    output reg [31:0] v0_c, v1_c
);
    reg [31:0] temp_v0;
    always @(v0_p, v1_p, sum, k0, k1, k2, k3) begin
        temp_v0 = v0_p + (((v1_p << 4) + k0) ^ (v1_p + sum) ^ ((v1_p >> 5) + k1));
        v1_c = v1_p + (((temp_v0 << 4) + k2) ^ (temp_v0 + sum) ^ ((temp_v0 >> 5) + k3));
        v0_c = temp_v0;
    end
endmodule

