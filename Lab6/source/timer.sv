module timer (
    input wire clk,
    input wire n_rst,
    input wire enable_timer,
    output wire shift_enable,
    output wire packet_done
);

    reg [3:0] clk_count;
    reg clk_rollover_flag;
    reg bit_rollover_flag;
    flex_counter 
    #(.NUM_CNT_BITS(4)) 
    CLK_COUNTER (.clk(clk), .n_rst(n_rst), .clear(1'b0), .count_enable(enable_timer), 
    .rollover_val(4'b1001), .count_out(clk_count), .rollover_flag(clk_rollover_flag));

    assign shift_enable = (clk_count == 4'd5);

    flex_counter 
    #(.NUM_CNT_BITS(4)) 
    BIT_COUNTER (.clk(shift_enable), .n_rst(n_rst), .clear(1'b0), .count_enable(enable_timer), 
    .rollover_val(4'b1000), .count_out(clk_count), .rollover_flag(bit_rollover_flag));

    assign packet_done = bit_rollover_flag;


endmodule