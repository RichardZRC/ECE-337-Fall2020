module flex_stp_sr 
# (
    parameter NUM_BITS = 4,
    parameter SHIFT_MSB = 1
)
(
    input reg clk,
    input reg n_rst, 
    input reg serial_in,
    input reg shift_enable,
    output reg [NUM_BITS - 1 : 0] parallel_out
);

    reg next_output = [NUM_BITS - 1 : 0];

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst = 0) begin
            parallel_out <= 1'b0;
        end else begin
            parallel_out <= next_output;
        end
    end

    always_comb begin
        if (SHIFT_MSB == 1) begin
            if (shift_enable == 1) begin
                next_output[NUM_BITS - 2 : 0] = parallel_out[NUM_BITS - 1 : 1];
                next_output[NUM_BITS - 1] = serial_in;
            end else begin
                next_output = parallel_out;
            end
        end else begin
            if (shift_enable == 1) begin
                next_output[NUM_BITS - 1 : 1] = parallel_out[NUM_BITS - 2 : 0];
                next_output[0] = serial_in;
            end else begin
                next_output = parallel_out;
            end
        end
    end 

endmodule