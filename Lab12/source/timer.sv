module timer (
    input wire clk,
    input wire n_rst,
    input wire stuff_bit,
    input wire enable,
    input wire clear,  // from rcu??? need this???
    output wire shift,
    output reg one_byte_time 
);
    reg [3:0] clk_count1, clk_count2;
    reg [3:0] bit_count1, bit_count2;
    reg clk_rollover_flag;
    reg bit_rollover_flag;
    wire shift2;
    wire timer_clear;
    wire timer_enable;
    
    assign timer_enable = enable && (~stuff_bit);

    flex_counter #(.NUM_CNT_BITS(4)) CLK_COUNTER (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(enable),
        .rollover_val(4'b1000),
        .count_out(clk_count1),
        .rollover_flag(clk_rollover_flag)
    );

    assign shift = (clk_count1 == 4'd1);

    flex_counter #(.NUM_CNT_BITS(4)) BIT_COUNTER (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(shift),
        .rollover_val(4'b1000),
        .count_out(bit_count1),
        .rollover_flag()
    );

       flex_counter #(.NUM_CNT_BITS(4)) CLK_COUNTER_2 (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(timer_enable),
        .rollover_val(4'b1000),
        .count_out(clk_count2),
        .rollover_flag()
    );

    assign shift2 = (clk_count2 == 4'd1);

    flex_counter #(.NUM_CNT_BITS(4)) BIT_COUNTER_2 (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(shift2),
        .rollover_val(4'b1000),
        .count_out(bit_count2),
        .rollover_flag(one_byte_time)
    );

endmodule