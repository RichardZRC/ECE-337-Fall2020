module adder_1bit (
    input reg a,
    input reg b,
    input reg carry_in,
    output reg sum,
    output reg carry_out
);

    always_comb begin
        sum = carry_in ^ (a ^ b);
        cout = ((! carry_in) & b & a) | (carry_in & (b | a));
    end

endmodule