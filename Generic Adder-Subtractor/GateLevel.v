module GateLevelAS #(parameter N = 4) (
    input [N-1:0] A,
    input [N-1:0] B,
    input Op,             // Operation: 0 for addition, 1 for subtraction
    output [N-1:0] S,
    output Cout
);

    wire [N-1:0] C;       // Carry signals between full adders
    wire [N-1:0] BxOp;    // B xor Op
    
    xor(BxOp[0], B[0], Op);
    GateLevelFA fa0(
        A[0], 
        BxOp[0], 
        Op, 
        S[0], 
        C[0]
    );

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : full_adders
            xor(BxOp[i], B[i], Op);
            GateLevelFA fa(
                A[i],
                BxOp[i],
                C[i-1],
                S[i],
                C[i]
            );
        end
    endgenerate

    buf(Cout, C[N-1]);

endmodule

module GateLevelFA(
    input a, b, cin,
    output s, cout
);
    xor(l,a,b);
    xor(s,l,cin);

    and(m,l,cin);
    and(n,a,b);

    or(cout,m,n);
    
endmodule