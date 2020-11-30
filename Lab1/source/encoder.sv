module encoder (
	input wire [30:0] in,
	output reg [4:0] out
);
	integer i;
	always @(*) begin
		out = 5'b00000;
		for (i = 30; i >= 0; i = i - 1) begin
			if (in[i] == 1) begin
				out = i;
			end
		end
	end
endmodule