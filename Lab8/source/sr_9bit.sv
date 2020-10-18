module sr_9bit (
    input wire clk,
    input wire n_rst,
    input wire shift_strobe,
    input wire serial_in,
    input wire [3:0] data_size,
    output reg [7:0] packet_data,
    output wire stop_bit
);

    reg [8:0] parallel_out;
    flex_stp_sr #(.NUM_BITS(9), .SHIFT_MSB(0)) SR1 (.clk(clk), .n_rst(n_rst), .serial_in(serial_in),
     .shift_enable(shift_strobe), .parallel_out(parallel_out));
    
    // assign packet_data = parallel_out[7:0];
    assign stop_bit = parallel_out[8];

    always_comb begin: 
        if (data_size == 5) begin
            packet_data = {3'b0, parallel_out[7:3]};
        end else if (data_size == 7) begin
            packet_data = {1'b0, parallel_out[7:1]};
        end else begin
            packet_data = parallel_out[7:0];
        end
    end
endmodule