module sr_9bit (
    input wire clk,
    input wire n_rst,
    input wire shift_strobe,
    input wire serial_in,
    output wire [7:0] packet_data,
    output wire stop_bit
);

    reg [8:0] parallel_out;
    flex_stp_sr (.NUM_BITS(9), .SHIFT_MSB(0)) SR1 (.clk(shift_strobe), .n_rst(n_rst), .serial_in(serial_in),
     .shift_enable(1'b1), .parallel_out(parallel_out));
    
    assign packet_data = parallel_out[7:0];
    assign stop_bit = parallel_out[8];

endmodule