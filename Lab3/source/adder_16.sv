module adder_16
(
	input wire [15:0] a,
	input wire [15:0] b,
	input wire carry_in,
	output wire [15:0] sum,
	output wire overflow
);
	assign sum = ((a + b + carry_in) % (2 ** 16));
	assign overflow = ((a + b + carry_in) / (2 ** 16));

endmodule

