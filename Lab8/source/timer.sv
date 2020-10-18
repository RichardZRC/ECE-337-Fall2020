module timer (
    input wire clk,
    input wire n_rst,
    input wire enable_timer,
    input wire [13:0] bit_period,
    input wire [3:0] data_size,
    output wire shift_enable,
    output wire packet_done
    //TODO: delete test signal
    // output reg [3:0] bit_count
);

    reg [3:0] clk_count;
    reg [3:0] bit_count;
    reg clk_rollover_flag;
    reg bit_rollover_flag;
    wire timer_clear;
    assign timer_clear = (enable_timer == 1'b0);
    flex_counter #(.NUM_CNT_BITS(14)) CLK_COUNTER (.clk(clk), .n_rst(n_rst), .clear(timer_clear), .count_enable(enable_timer), 
    .rollover_val(bit_period), .count_out(clk_count), .rollover_flag(clk_rollover_flag));

    assign shift_enable = (clk_count == (bit_period / 2 - 1));

    flex_counter #(.NUM_CNT_BITS(4)) BIT_COUNTER (.clk(clk), .n_rst(n_rst), .clear(timer_clear), .count_enable(shift_enable), 
    .rollover_val(data_size), .count_out(bit_count), .rollover_flag(bit_rollover_flag));

    assign packet_done = bit_rollover_flag;


endmodule
