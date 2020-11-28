module timer (
    input wire clk,
    input wire n_rst,
    input wire stuff_bit,
    input wire enable,
    input wire clear,  // from rcu??? need this???
    output wire shift,
    output reg one_byte
);
    reg [3:0] clk_count;
    reg [3:0] bit_count;
    reg clk_rollover_flag;
    reg bit_rollover_flag;
    wire timer_clear;
    wire timer_enable;
    
    assign timer_enable = enable && (!stuff_bit);

    flex_counter #(.NUM_CNT_BITS(4)) CLK_COUNTER (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(timer_enable),
        .rollover_val(4'b1000),
        .count_out(clk_count),
        .rollover_flag(clk_rollover_flag)
    );

    assign shift = (clk_count == 4'd1);

    flex_counter #(.NUM_CNT_BITS(4)) BIT_COUNTER (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(shift),
        .rollover_val(4'b1000),
        .count_out(bit_count),
        .rollover_flag(one_byte)
    );

endmodule