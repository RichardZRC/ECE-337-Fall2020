module moore (
    input reg clk,
    input reg n_rst,
    input reg i,
    output reg o
);

    localparam [2:0] s0 = 3'b001;
    localparam [2:0] s1 = 3'b010;
    localparam [2:0] s2 = 3'b011;
    localparam [2:0] s3 = 3'b100;
    localparam [2:0] s4 = 3'b101;
    reg [2:0] state, next_state;

    always_ff @ (posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            state <= s0;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            s0: begin
                if (i == 1'b1) begin
                    next_state = s1;
                end else begin
                    next_state = s0;
                end
            end

            s1: begin
                if (i == 1'b1) begin
                    next_state = s2;
                end else begin
                    next_state = s0;
                end
            end

            s2: begin
                if (i == 1'b1) begin
                    next_state = s2;
                end else begin
                    next_state = s3;
                end
            end

            s3: begin
                if (i == 1'b1) begin
                    next_state = s4;
                end else begin
                    next_state = s0;
                end
            end

            s4: begin
                if (i == 1'b1) begin
                    next_state = s2;
                end else begin
                    next_state = s0;
                end
            end
        endcase
    end

    always_comb begin
        if (state == s4) begin
            o = 1'b1;
        end else begin
            o = 1'b0;
        end
    end

endmodule