module sync_low (
    input wire clk,
    input wire n_rst,
    input wire async_in,
    output reg sync_out
);
    reg sync_temp;
    always_ff @ (posedge clk, negedge n_rst) begin
        if (1'b0 == n_rst) begin
            sync_temp <= 1'b0;
            sync_out <= 1'b0;
        end
        else begin
            sync_out <= sync_temp;
            sync_temp <= async_in;
        end
    end

endmodule