module flex_pts_sr 
#(
    parameter NUM_BITS = 4,
    parameter SHIFT_MSB = 0
)
(
    input reg clk,
    input reg n_rst,
    input reg shift_enable,
    input reg load_enable,
    input reg [NUM_BITS - 1 : 0] parallel_in,
    output reg serial_out
);
    reg [NUM_BITS - 3 : 0] next_output;
    reg [NUM_BITS - 3 : 0] temp_output;
    reg first_bit;
    reg next_serial;

    always_ff @ (posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            serial_out <= 1'b1;
            temp_output <= '1;
        end else begin
            serial_out <= next_serial;
            temp_output <= next_output;
            first_bit <= (SHIFT_MSB == 1) ? parallel_in[NUM_BITS - 1] : parallel_in[0];
        end
    end

    always_comb begin
        if (SHIFT_MSB == 1) begin
            if (load_enable == 1'b1) begin
                next_serial = parallel_in[0];
                next_output = parallel_in[NUM_BITS - 2 : 1];
            end else if (shift_enable == 1'b1) begin
                next_serial = temp_output[0];
                next_output[NUM_BITS - 4 : 0] = temp_output[NUM_BITS - 3: 1];
                next_output[NUM_BITS - 3] = first_bit;
            end else begin
                next_serial = serial_out;
                next_output = temp_output;
            end
        end else begin
            if (load_enable == 1'b1) begin
                next_serial = parallel_in[NUM_BITS - 1];
                next_output = parallel_in[NUM_BITS - 2 : 1];
            end else if (shift_enable == 1'b1) begin
                next_serial = temp_output[NUM_BITS - 3];
                next_output[NUM_BITS - 3 : 1] = temp_output[NUM_BITS - 4: 0];
                next_output[0] = first_bit;
            end else begin
                next_serial = serial_out;
                next_output = temp_output;
            end
        end
    end

endmodule