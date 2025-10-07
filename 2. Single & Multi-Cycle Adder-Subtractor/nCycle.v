module AdderSubtractor #(parameter N = 4) (
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    input wire rst,
    input wire addsub,
    input wire start,
    input wire clk,
    output reg [N-1:0] sum,
    output reg cout,
    output reg done,
    output reg calculating
);

    // Internal registers to store inputs and carry signals
    reg [N-1:0] regA, regB;
    reg regOp;
    reg [N-1:0] partialSum;
    reg [N:0] carry;
    reg [2:0] i;  // 3-bit register to keep track of bit position

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= {N{1'b0}};
            cout <= 0;
            done <= 0;
            calculating <= 0;
            i <= 0;
            carry <= 0;
        end 
        else if (start && !calculating) begin
            // Store inputs and initialize computation on start signal
            regA <= A;
            regB <= (addsub) ? ~B : B;  // Subtraction: take 2's complement of B if addsub is 1
            regOp <= addsub;
            partialSum <= 0;
            carry[0] <= addsub; // Initial carry based on operation
            i <= 0;
            calculating <= 1;
            done <= 0;
        end
        else if (calculating) begin
            // Perform addition/subtraction bit-by-bit
            if (i < N) begin
                partialSum[i] <= regA[i] ^ regB[i] ^ carry[i];
                carry[i + 1] <= (regA[i] & regB[i]) |
                                (regA[i] & carry[i]) |
                                (regB[i] & carry[i]);
                i <= i + 1;
            end 
            else begin
                // Calculation completed
                sum <= partialSum;
                cout <= carry[N];
                done <= 1;
                calculating <= 0;
            end
        end 
        else begin
            // Idle state
            done <= 0;
        end
    end
endmodule
