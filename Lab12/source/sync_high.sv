module sync_high (
    input reg clk,
    input reg n_rst,
    input reg async_in,
    output reg sync_out
);

    reg sync_temp;
    always_ff @ (posedge clk, negedge n_rst) begin
        if (1'b0 == n_rst) begin
            sync_temp <= 1'b1;
            sync_out <= 1'b1;
        end
        else begin
            sync_temp <= async_in;
            sync_out <= sync_temp;
        end
    end

endmodule