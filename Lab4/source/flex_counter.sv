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
    reg rollover_flag_temp;

    always_ff @ (posedge clk, negedge n_rst) begin
        if (n_rst == 0) begin
            count_out <= 0;
        end
        else begin
            count_out <= next_count;
        end

        if (n_rst == 0) begin
            rollover_flag <= 0;
        end
        else begin
            rollover_flag <= rollover_flag_temp;
        end
    end

    always_comb begin
        // next_count = 0;
        // rollover_flag_temp = 0;
        if (clear == 1'b1) begin
            next_count = 0;
            rollover_flag_temp = 0;
        end
        else if (count_enable == 1'b0) begin
            next_count = count_out;
            rollover_flag_temp = rollover_flag;
        end
        else if (count_out == rollover_val) begin
            next_count = 1;
            rollover_flag_temp = 0;
        end 
        else if (count_out == (rollover_val - 1)) begin
            rollover_flag_temp = 1;
            next_count = count_out + 1;
        end
        else begin
            next_count = count_out + 1;
            rollover_flag_temp = 0;
        end
    end


endmodule
