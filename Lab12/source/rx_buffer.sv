module rx_buffer (
    input wire [15:0] rcv_data,
    input wire w_enable,
    input wire r_enable,
    input wire clk,
    input wire n_rst,
    output reg data_loaded,
    output reg [7:0] rx_packet_data
);

    reg  next_data_loaded;
    reg [7:0] next_rx_data, rx_data, next_rx_packet_data;
    always_ff @(posedge clk, negedge n_rst) begin: REG
        if (n_rst == 1'b0) begin
            rx_packet_data <= '0;
            data_loaded <= '0;
            rx_data <= '0;
        end else begin
            // rx_data <= next_rx_data;
            data_loaded <= next_data_loaded;
            rx_packet_data <= next_rx_packet_data;
        end
    end

    always_comb begin: NEXT_STATE
        next_data_loaded = data_loaded;
        // next_rx_data = rx_data;
        next_rx_packet_data = rx_packet_data;
        if (w_enable) begin
            next_data_loaded = 1'b1;
            next_rx_packet_data = rcv_data;
        end

        // if (r_enable) begin
        //     next_rx_packet_data = rx_data;
        //     next_data_loaded = '0;
        // end
    end

endmodule