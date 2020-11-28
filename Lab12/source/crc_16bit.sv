module crc_16bit (
    input wire clk,
    input wire n_rst,
    input wire d_orig,
    input wire clear,
    input wire shift_enable,
    input wire eop,
    output reg err
);

    reg [15:0] crc_data, next_crc;
    wire reg_enable;
    assign reg_enable = (shift_enable) && (!eop);

    always_ff @(posedge clk, negedge n_rst) begin: REG
        if (n_rst == 0) begin
            crc_data <= '0;
        end else begin
            crc_data <= next_crc;
        end        
    end

    assign inv = d_orig ^ crc_data[15];

    always_comb begin: NEXT_STATE
        next_crc = crc_data;
        if (clear) begin
            next_crc = '0;
        end else if (reg_enable) begin
            next_crc[15] = crc_data[14] ^ inv;
            next_crc[14:3] = crc_data[13:2];
            next_crc[2] = crc_data[1] ^ inv;
            next_crc[1] = crc_data[0];
            next_crc[0] = inv;
        end
    end

    assign err = eop && (crc_data != 16'h800D);

endmodule