module AdderSubtractor #(parameter N = 4) (
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    input wire rst,
    input wire addsub,
    input wire start,
    input wire clk,
    output reg [N-1:0] sum,
    output reg cout,
    output reg done
);

    wire [N-1:0] sumComb;
    wire coutComb;

    AdderSubtractorComb #(N) AS (
        .A(A),
        .B(B),
        .Op(addsub),
        .S(sumComb),
        .Cout(coutComb)
    );

    always @(posedge clk) 
    begin
        if (rst) 
        begin
            sum <= {N{1'b0}};
            cout <= 0;
            done <= 0;
        end
        else if (start) 
        begin
            sum <= sumComb;
            cout <= coutComb;
            done <= 1;
        end 
        else 
        begin
            done <= 0;
        end
    end
endmodule

module AdderSubtractorComb #(parameter N) (
    input [N-1:0] A,
    input [N-1:0] B,
    input Op,             // Operation: 0 for addition, 1 for subtraction
    output reg [N-1:0] S,
    output reg Cout
);

    reg [N-1:0] C;
    reg [N-1:0] BxOp;
    integer i;

    always @(A, B, Op)
    begin
        BxOp[0] = B[0] ^ Op;

        S[0] = A[0] ^ BxOp[0] ^ Op;
        C[0] = (A[0] & BxOp[0]) | (BxOp[0] & Op) | (A[0] & Op);

        for (i = 1; i < N; i = i + 1) 
        begin
            BxOp[i] = B[i] ^ Op;

            S[i] = A[i] ^ BxOp[i] ^ C[i-1];
            C[i] = (A[i] & BxOp[i]) | (BxOp[i] & C[i-1]) | (A[i] & C[i-1]);
        end

        Cout = C[N-1];
    end
endmodule
