// File name:   adder_16.sv
// Created:     1/19/2015
// Author:      Tim Pritchett
// Version:     1.0  Initial Design Entry
// Description: 16 bit adder design wrapper for synthesis optimization seciton of Lab 2
`timescale 1ns / 100ps

module adder_16bit
(
	input wire [15:0] a,
	input wire [15:0] b,
	input wire carry_in,
	output wire [15:0] sum,
	output wire overflow
);
	adder_nbit #(.BIT_WIDTH(16)) A1 (.a(a), .b(b), .carry_in(carry_in), .sum(sum), .overflow(overflow));

	always @ (a, b, carry_in) begin
		#(2) assert (((a + b + carry_in) % (2 ** 16)) == sum)
		else $error("the sum of 16-bit adder is not correct!")
	end
endmodule
