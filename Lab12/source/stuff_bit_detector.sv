module stuff_bit_detector (
    input wire clk,
    input wire n_rst,
    input wire eop,
    input wire d_orig,
    input wire shift_enable,  //need???
    output reg stuff_bit
);
    reg [2:0] bit_count;
    wire enable;
    wire clear;
    assign enable = (d_orig == 1) && !eop && shift_enable;
    assign clear = (d_orig == 0) || eop;
    flex_counter #(.NUM_CNT_BITS(3)) BIT_COUNTER (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(enable),
        .rollover_val(3'b110),
        .count_out(bit_count),
        .rollover_flag(stuff_bit)
    );

endmodule