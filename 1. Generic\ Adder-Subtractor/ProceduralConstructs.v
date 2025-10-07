module ProceduralConstructAS #(parameter N = 4) (
    input [N-1:0] A,
    input [N-1:0] B,
    input Op,             // Operation: 0 for addition, 1 for subtraction
    output reg [N-1:0] S,
    output reg Cout
);

    reg [N-1:0] C;       // Carry signals between full adders
    reg [N-1:0] BxOp;    // B xor Op
    integer i;            // Loop iterator

    always @(A, B, Op)
    begin
        BxOp[0] = B[0] ^ Op;

        S[0] = A[0] ^ BxOp[0] ^ Op;
        C[0] = (A[0] & BxOp[0]) | (BxOp[0] & Op) | (A[0] & Op);

        for (i = 1; i < N; i = i + 1) begin
            BxOp[i] = B[i] ^ Op;

            S[i] = A[i] ^ BxOp[i] ^ C[i-1];
            C[i] = (A[i] & BxOp[i]) | (BxOp[i] & C[i-1]) | (A[i] & C[i-1]);
        end

        Cout = C[N-1];
    end

endmodule