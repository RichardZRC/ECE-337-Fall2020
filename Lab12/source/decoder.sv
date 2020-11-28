module decoder (
    input wire d_plus,
    input wire shift_enable,
    input wire eop,  //do not decode eop???
    input wire clk,
    input wire n_rst,
    output reg d_orig
);

    reg next_current_bit, next_last_bit, current_bit, last_bit;

    always_ff @(posedge clk, negedge n_rst) begin: BIT_REG
        if (n_rst == 1'b0) begin
            current_bit = 1'b1;
            last_bit = 1'b1;
        end else begin
            current_bit <= next_current_bit;
            last_bit <= next_last_bit;
        end
    end

    always_comb begin: NEXT_BIT_LOGIC
        next_current_bit = current_bit;
        if (shift_enable && !eop) begin
            next_current_bit = d_plus;
        end
    end

    always_comb begin: OUTPUT_LOGIC
        next_last_bit = last_bit;
        if (shift_enable && !eop) begin
            next_last_bit = current_bit;
        end
        if (current_bit == last_bit) begin
            d_orig = 1;
        end else begin
            d_orig = 0;
        end
    end

endmodule