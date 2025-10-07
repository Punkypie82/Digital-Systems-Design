module AdderSubtractor #(parameter N = 4) (
    input clk,
    input nrst,
    input [N-1:0] A,
    input [N-1:0] B,
    input addsub,
    output reg [N-1:0] SUM,
    output reg cout
);
    reg [N-1:0] pipelineSum [0:N-1];
    reg [N-1:0] pipelineA [0:N-1];
    reg [N-1:0] pipelineB [0:N-1];
    reg pipelineC [0:N];
    reg pipelineAddsub [0:N];
    integer i;

    always @(posedge clk) begin
        if (!nrst) begin
            for (i = 0; i <= N; i = i + 1) begin
                pipelineSum[i] <= 0;
                pipelineA[i] <= 0;
                pipelineB[i] <= 0;
                pipelineC[i] <= 0;
                pipelineAddsub[i] <= 0;
            end
            SUM <= 0;
            cout <= 0;
        end else begin
            pipelineA[0] <= A;
            pipelineB[0] <= addsub ? ~B : B;
            pipelineC[0] <= addsub ? 1'b1 : 1'b0;
            pipelineAddsub[0] <= addsub;

            for (i = 0; i < N; i = i+1) begin
                pipelineA[i+1] <= pipelineA[i];
                pipelineB[i+1] <= pipelineB[i];
                pipelineSum[i+1] <= pipelineSum[i];
                pipelineAddsub[i+1] <= pipelineAddsub[i];

                pipelineSum[i][i] <= pipelineA[i][i] ^ pipelineB[i][i] ^ pipelineC[i];
                pipelineC[i+1] <= (pipelineA[i][i] & pipelineB[i][i]) |
                                    (pipelineA[i][i] & pipelineC[i]) |
                                    (pipelineB[i][i] & pipelineC[i]);
            end

            SUM <= pipelineSum[N-1];
            cout <= (pipelineAddsub[N]) ? ~pipelineC[N] : pipelineC[N]; // Borrow/Carry Logic
        end
    end
endmodule
