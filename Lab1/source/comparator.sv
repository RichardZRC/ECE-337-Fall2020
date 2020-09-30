module idcs (
	input reg D_s;
	input reg Eng01;
	output reg Waiting,
	output reg Counting,
	output reg DataReady
);
	localparam [1:0] Idle = 2'b00;
	localparam [1:0] Dwait = 2'b01;
	localparam [1:0] Count = 2'b10;
	localparam [1:0] Done = 2'b11;

	reg [1:0] state, next_state;

	always_ff @ (posedge clk, negedge n_rst) begin
		if (n_rst == 1'b0) begin
			state <= Idle;
		end else begin
			state <= next_state;
		end
	end

	always_comb begin
		case(state)
			Waiting:begin
				if (Eng01 == 1'b1)
					next_state = Dwait;
			end
			Dwait:begin
				if (D_s == 1'b1)
					next_state = Count;
			end
			Count:begin
				if (Eng01)
					next_state = Dwait;
				else if (!D_s & !Eng01)
					next_state = Done;
			end
			Done:begin
				if (Eng01)
					next_state = Dwait;
			end
			default:begin
				next_state = state;
			end
		endcase
	end

	always_comb begin
		Waiting = 1'b0;
		Counting = 1'b0;
		DataReady = 1'b0;
		if (state == Dwait) begin
			Waiting = 1'b1;
		end
		else if (state == Count) begin
			Counting = 1'b1;
		end 
		else if (state == Done) begin
			DataReady = 1'b1;
		end		
	end

endmodule