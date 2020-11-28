module usb_rx (
    input wire clk,
    input wire n_rst,
    input wire d_plus,
    input wire d_minus,
    input wire r_enable,
    output reg [7:0] rx_packet_data,
    output reg [2:0] rx_packet,
    output reg store_rx_packet,
    output reg r_error,
    output reg packet_done,
    output reg data_loaded
);
    reg d_plus_sync, d_minus_sync, edge_start, eop, d_orig, shift_enable, stuff_bit, receiving, timer_clear, one_byte, w_enable_buffer, crc_clear, two_byte;
    reg [15:0] rcv_data;

    sync_high sync_high (
        .clk(clk),
        .n_rst(n_rst),
        .async_in(d_plus),
        .sync_out(d_plus_sync)
    );

    sync_low sync_low (
        .clk(clk),
        .n_rst(n_rst),
        .async_in(d_minus),
        .sync_out(d_minus_sync)
    );

    edge_detector edge_detector (
        .clk(clk),
        .n_rst(n_rst),
        .d_sync(d_plus_sync),
        .edge_start(edge_start)
    );

    decoder decoder (
        .clk(clk),
        .n_rst(n_rst),
        .eop(eop),
        .d_orig(d_orig),
        .shift_enable(shift_enable),
        .d_plus(d_plus_sync)
    );

    eop_detector eop_detector (
        .d_plus(d_plus_sync),
        .d_minus(d_minus_sync),
        .eop(eop)
    );

    stuff_bit_detector stuff_bit_detector (
        .clk(clk),
        .n_rst(n_rst),
        .eop(eop),
        .shift_enable(shift_enable),
        .stuff_bit(stuff_bit),
        .d_orig(d_orig)
    );

    timer timer (
        .clk(clk),
        .n_rst(n_rst),
        .stuff_bit(stuff_bit),
        .enable(receiving),
        .clear(timer_clear),
        .shift(shift_enable)
    );

    shift_register shift_register (
        .clk(clk),
        .n_rst(n_rst),
        .shift_enable(shift_enable),
        .clear(timer_clear),
        .d_orig(d_orig),
        .rcv_data(rcv_data),
        .one_byte(one_byte),
        .two_byte(two_byte)
    );

    rcu rcu (
        .clk(clk),
        .n_rst(n_rst),
        .shift_enable(shift_enable),
        .eop(eop),
        .edge_start(edge_start),
        .one_byte(one_byte),
        .crc5_err(crc5_err),
        .crc16_err(crc16_err),
        .rcv_data(rcv_data),
        .store_rx_packet(store_rx_packet),
        .rx_packet(rx_packet),
        .receiving(receiving),
        .w_enable_buffer(w_enable_buffer),
        .r_error(r_error),
        .timer_clear(timer_clear),
        .packet_done(packet_done),
        .crc_clear(crc_clear),
        .two_byte(two_byte)
    );

    crc_5bit crc_5bit (
        .clk(clk),
        .n_rst(n_rst),
        .d_orig(d_orig),
        .clear(crc_clear),
        .shift_enable(shift_enable),
        .eop(eop),
        .err(crc5_err)
    );

    crc_16bit crc_16bit (
        .clk(clk),
        .n_rst(n_rst),
        .d_orig(d_orig),
        .clear(crc_clear),
        .shift_enable(shift_enable),
        .eop(eop),
        .err(crc16_err)
    );

    rx_buffer rx_buffer (
        .clk(clk),
        .n_rst(n_rst),
        .rcv_data(rcv_data),
        .w_enable(w_enable_buffer),
        .r_enable(r_enable),
        .data_loaded(data_loaded),
        .rx_packet_data(rx_packet_data)
    );

endmodule