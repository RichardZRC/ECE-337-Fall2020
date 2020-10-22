module apb_uart_rx (
    input wire clk,
    input wire n_rst,
    input wire serial_in,
    input wire psel,
    input wire [2:0] paddr,
    input wire penable,
    input wire pwrite,
    input wire [7:0] pwdata,
    output wire [7:0] prdata,
    output wire pslverr
);

    wire data_ready, data_read, overrun_error, framing_error;
    wire [3:0] data_size;
    wire [7:0] rx_data;
    wire [13:0] bit_period;


    apb_slave controller (
        .clk(clk),
        .n_rst(n_rst),
        .rx_data(rx_data),
        .data_ready(data_ready),
        .overrun_error(overrun_error),
        .framing_error(framing_error),
        .data_read(data_read),
        .psel(psel),
        .paddr(paddr),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata),
        .pslverr(pslverr),
        .data_size(data_size),
        .bit_period(bit_period)
    );

    rcv_block rcv (
        .clk(clk),
        .n_rst(n_rst),
        .data_size(data_size),
        .bit_period(bit_period),
        .serial_in(serial_in),
        .data_read(data_read),
        .rx_data(rx_data),
        .data_ready(data_ready),
        .overrun_error(overrun_error),
        .framing_error(framing_error)
    );

endmodule