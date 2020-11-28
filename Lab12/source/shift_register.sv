module shift_register (
    input wire shift_enable,
    input wire d_orig,
    input wire clk,
    input wire n_rst,
    output wire [7:0] rcv_data
);

    reg [15:0] temp_reg;
    reg shift_reserve1, shift_reserve2;
    always_ff @(posedge clk, negedge n_rst) begin: SHIFT_REG
        if (n_rst == 1'b0) begin
            shift_reserve1 <= '0;
            shift_reserve2 <= '0;
        end else begin
            shift_reserve2 <= shift_reserve1;
            shift_reserve1 <= shift_enable;
        end
    end
    flex_stp_sr #(.NUM_BITS(16), .SHIFT_MSB(0)) SR (
        .clk(clk),
        .n_rst(n_rst),
        .serial_in(d_orig),
        .shift_enable(shift_reserve2),
        .parallel_out(temp_reg)
    );

    assign rcv_data = temp_reg[15:8];

endmodule