module rcv_block (
    input wire clk,
    input wire n_rst,
    input wire serial_in,
    input wire data_read,
    input wire [3:0] data_size,
    input wire [13:0] bit_period,
    output reg [7:0] rx_data,
    output reg data_ready,
    output reg overrun_error,
    output reg framing_error
    // TODO: delete test signals
    // output reg shift_strobe,
    // output reg [7:0] packet_data,
    // output reg [3:0] bit_count //test signal
);

    wire start_bit_detected;
    wire new_package_detected;
    wire shift_strobe;
    wire [7:0] packet_data;
    wire stop_bit;
    wire sbc_enable;
    wire sbc_clear;
    wire enable_timer;
    wire packet_done;
    wire load_buffer;
    

    start_bit_det A1 (
        .clk(clk),
        .n_rst(n_rst),
        .serial_in(serial_in),
        .start_bit_detected(start_bit_detected),
        .new_package_detected(new_package_detected)
        );



    sr_9bit A2 (
        .clk(clk),
        .n_rst(n_rst),
        .serial_in(serial_in),
        .shift_strobe(shift_strobe),
        .data_size(data_size),
        .packet_data(packet_data),
        .stop_bit(stop_bit)
    );

    stop_bit_chk A3 (
        .clk(clk),
        .n_rst(n_rst),
        .stop_bit(stop_bit),
        .sbc_enable(sbc_enable),
        .sbc_clear(sbc_clear),
        .framing_error(framing_error)
    );

    timer A4 (
        .clk(clk),
        .n_rst(n_rst),
        .enable_timer(enable_timer),
        .shift_enable(shift_strobe),
        .packet_done(packet_done)
        .bit_period(bit_period),
        .data_size(data_size)
        // .bit_count(bit_count) //test signal
    );

    rcu A5 (
        .clk(clk),
        .n_rst(n_rst),
        .start_bit_detected(start_bit_detected),
        .packet_done(packet_done),
        .framing_error(framing_error),
        .sbc_clear(sbc_clear),
        .sbc_enable(sbc_enable),
        .load_buffer(load_buffer),
        .enable_timer(enable_timer)
    );

    rx_data_buff A6 (
        .clk(clk),
        .n_rst(n_rst),
        .load_buffer(load_buffer),
        .packet_data(packet_data),
        .data_read(data_read),
        .rx_data(rx_data),
        .data_ready(data_ready),
        .overrun_error(overrun_error)
    );



endmodule
