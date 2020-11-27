module shift_register (
    input wire shift_enable,
    input wire d_orig,
    input wire clk,
    input wire n_rst,
    output wire [7:0] rcv_data
);

    reg [15:0] temp_reg;
    flex_stp_sr #(.NUM_BITS(16), .SHIFT_MSB(0)) SR (
        .clk(clk),
        .n_rst(n_rst),
        .serial_in(d_orig),
        .shift_enable(shift_enable),
        .parallel_out(temp_reg)
    );

    assign rcv_data = temp_reg[7:0];

endmodule