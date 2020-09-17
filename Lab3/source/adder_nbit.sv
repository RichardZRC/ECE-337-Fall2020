`timescale 1ns / 100ps

module adder_nbit 
#(
    parameter BIT_WIDTH = 4
)
(
    input wire [BIT_WIDTH - 1 : 0] a,
    input wire [BIT_WIDTH - 1 : 0] b,
    input wire carry_in,
    output wire [BIT_WIDTH - 1 : 0] sum,
    output wire overflow
);

    wire [BIT_WIDTH:0] carrys;
    genvar i;

    assign carrys[0] = carry_in;

    generate
        for (i = 0; i <= BIT_WIDTH - 1; i = i + 1) begin
            adder_1bit IX (.a(a[i]), .b(b[i]), .carry_in(carrys[i]), .sum(sum[i]), 
            .carry_out(carrys[i + 1]));
        end
    endgenerate

    always @ (a, b, carry_in) begin
        #(2) assert (((a + b + carry_in) % (2 ** BIT_WIDTH)) == sum)
        else $error("the sum of n-bit adder is not correct!");
    end
    assign overflow = carrys[BIT_WIDTH];

endmodule
