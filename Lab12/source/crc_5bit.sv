module crc_5bit (
    input wire clk,
    input wire n_rst,
    input wire d_orig,
    input wire clear,
    input wire shift_enable,
    input wire eop,
    output reg err
);

    reg [4:0] crc_data, next_crc;
    wire reg_enable;
    assign reg_enable = (shift_enable) && (!eop);

    always_ff @(posedge clk, negedge n_rst) begin: REG
        if (n_rst == 0) begin
            crc_data <= '0;
        end else begin
            crc_data <= next_crc;
        end        
    end

    assign inv = d_orig ^ crc[15];

    always_comb begin: NEXT_STATE
        next_crc = crc;
        if (clear) begin
            next_crc = '0;
        end else if (reg_enable) begin
            next_crc[4] = crc_data[3];
            next_crc[3] = crc_data[2];
            next_crc[2] = crc[1] ^ inv;
            next_crc[1] = crc[0];
        end
    end

    assign err = eop && (crc != 16'h800D);

endmodule