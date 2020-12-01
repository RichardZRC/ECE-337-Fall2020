module eop_detector (
    input wire d_plus,
    input wire d_minus,
    output reg eop
);

    reg next_eop;
    always_comb begin
        next_eop = 1'b0;
        if ((!d_plus) && (!d_minus)) begin
            next_eop = 1'b1;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            eop <= 1'b0;
        end else begin
            eop <= next_eop;
        end
    end

endmodule