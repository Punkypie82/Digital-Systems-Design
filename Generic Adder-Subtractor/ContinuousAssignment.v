module ContinuousAssignmentAS #(parameter N = 4) (
    input [N-1:0] A,
    input [N-1:0] B,
    input Op,             // Operation: 0 for addition, 1 for subtraction
    output [N-1:0] S,
    output Cout
);

    wire [N-1:0] C;       // Carry signals between full adders
    wire [N-1:0] BxOp;    // B xor Op
    
    assign BxOp[0] = B[0] ^ Op;
    ContinuousAssignmentFA fa0(
        A[0], 
        BxOp[0], 
        Op, 
        S[0], 
        C[0]
    );

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : full_adders
            assign BxOp[i] = B[i] ^ Op;
            ContinuousAssignmentFA fa(
                A[i],
                BxOp[i],
                C[i-1],
                S[i],
                C[i]
            );
        end
    endgenerate

    assign Cout = C[N-1];

endmodule

module ContinuousAssignmentFA(
    input a, b, cin,
    output s, cout
);
    assign s = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
    
endmodule