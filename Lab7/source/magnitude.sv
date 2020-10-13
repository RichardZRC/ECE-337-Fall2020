module magnitude (
    input wire [16:0] in,
    output wire [15:0] out
);
    reg [16:0] mag;
    reg [16:0] mag_temp;

    always_comb begin
        mag = in;
        if (mag[16] == 1'b1) begin
            mag[15:0] = ~in[15:0];
            mag[15:0] = mag[15:0] + 1;
        end
    end

    assign out = mag[15:0];

endmodule