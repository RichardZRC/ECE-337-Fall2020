`timescale 1ns / 100ps

module adder_1bit (
    input wire a,
    input wire b,
    input wire carry_in,
    output wire sum,
    output wire carry_out
);

    assign sum = carry_in ^ (a ^ b);
    assign carry_out = ((! carry_in) & b & a) | (carry_in & (b | a));

    always @ (a, b, carry_in) begin
        #(2) assert (((a + b + carry_in) % 2) == sum) 
        else   $error("the sum of 1-bit adder is not correct!");
    
    end

endmodule