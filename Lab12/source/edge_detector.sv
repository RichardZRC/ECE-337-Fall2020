module edge_detector (
    input wire clk,
    input wire n_rst,
    input wire d_sync,
    output wire edge
);

    reg old_sample;
    reg new_sample;
    reg sync_phase;

    always @ (negedge n_rst, posedge clk)
    begin : REG_LOGIC
    if(1'b0 == n_rst) begin
        old_sample  <= 1'b1; // Reset value to idle line value
        new_sample  <= 1'b1; // Reset value to idle line value
        sync_phase  <= 1'b1; // Reset value to idle line value
    end else begin
        old_sample  <= new_sample;
        new_sample  <= sync_phase;
        sync_phase  <= d_sync;
    end
    end

    // Output logic
    assign edge = old_sample ^ new_sample;

endmodule