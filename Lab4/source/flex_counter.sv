module flex_counter
# (
    parameter NUM_CNT_BITS = 3
)
(
    input reg clear,
    input reg n_rst,
    input reg clk,
    input reg count_enable,
    input reg [NUM_CNT_BITS - 1 : 0] rollover_val,
    output reg [NUM_CNT_BITS - 1 : 0] count_out,
    output reg rollover_flag
);

    reg [NUM_CNT_BITS - 1 : 0] next_count;

    always_ff @ (posedge clk, negedge n_rst) begin
        if (n_rst == 0) begin
            count_out <= 0;
        end
        else begin
            count_out <= next_count;
        end
    end

    always_comb begin
        if (clear == 1'b1) begin
            next_count = 0;
        end
        else if (count_enable == 1'b0) begin
            next_count = count_out;
        end
        else if (count_out == rollover_val) begin
            next_count = 1;
        end
        else begin
            next_count = count_out + 1;
        end
    end

endmodule
