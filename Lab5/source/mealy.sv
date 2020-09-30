module mealy (
    input reg clk,
    input reg n_rst,
    input reg i,
    output reg o
);
    localparam [1:0] s0 = 2'b00;
    localparam [1:0] s1 = 2'b01;
    localparam [1:0] s2 = 2'b10;
    localparam [1:0] s3 = 2'b11;

    reg [1:0] state, next_state;

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
                    o = 1'b0;
                end else begin
                    next_state = s0;
                    o = 1'b0;
                end               
            end

            s1: begin
                if (i == 1'b1) begin
                    next_state = s2;
                    o = 1'b0;
                end else begin
                    next_state = s0;
                    o = 1'b0;
                end
            end

            s2: begin
                if (i == 1'b1) begin
                    next_state = s2;
                    o = 1'b0;
                end else begin
                    next_state = s3;
                    o = 1'b0;
                end
            end

            s3: begin
                if (i == 1'b1) begin
                    next_state = s1;
                    o = 1'b1;
                end else begin
                    next_state = s0;
                    o = 1'b0;
                end
            end
        endcase
    end

endmodule