module 31t5 encoder (
	input wire [30:0] in,
	output reg [4:0] out
);
	integer i;
	always_comb begin: 
		out = '0;
		for (i = 30; i >= 0; i = i - 1) begin
			if (in[i] == 1) begin
				out = i;
			end
		end
	end
endmodule
endmodule