module flex_counter_5bit (
    input reg clear,
    input reg n_rst,
    input reg clk,
    input reg count_enable,
    input reg [4 : 0] rollover_val,
    output reg [4 : 0] count_out,
    output reg rollover_flag
);

    flex_counter #(.NUM_CNT_BITS) A1 (.clear(clear), .n_rst(n_rst), .clk(clk), .count_enable(count_enable),
     .rollover_val(rollover_val), .count_out(count_out), .rollover_flag(rollover_flag));

endmodule