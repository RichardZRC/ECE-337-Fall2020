`timescale 1ns / 10ps

module tb_usb_rx ();
    parameter CLK_PERIOD = 10;
    parameter NORM_DATA_PERIOD  = (8 * CLK_PERIOD);

    //DUT signals
    reg tb_clk;
    reg tb_n_rst;
    reg tb_d_plus;
    reg tb_d_minus;
    reg tb_r_enable;
    reg [7:0] tb_rx_packet_data;
    reg [2:0] tb_rx_packet;
    reg tb_store_rx_packet;
    reg tb_r_error;
    reg tb_packet_done;
    reg tb_data_loaded;

    reg tb_next_d_plus;
    reg tb_next_d_minus;
    reg tb_d_orig;


    //test case info
    integer tb_test_num;
    string tb_test_case;

    //test signals
    reg [7:0] tb_test_data;
    logic tb_check;
    logic tb_mismatch;

    //expected output
    reg [2:0] tb_expected_rx_packet;
    reg [7:0] tb_expected_rx_packet_data;
    reg tb_expected_store_rx_packet;
    reg tb_expected_r_error;
    reg tb_expected_packet_done;
    reg tb_expected_data_loaded;

    usb_rx DUT (
        .clk(tb_clk),
        .n_rst(tb_n_rst),
        .d_plus(tb_d_plus),
        .d_minus(tb_d_minus),
        .r_enable(tb_r_enable),
        .rx_packet_data(tb_rx_packet_data),
        .rx_packet(tb_rx_packet),
        .store_rx_packet(tb_store_rx_packet),
        .r_error(tb_r_error),
        .packet_done(tb_packet_done),
        .data_loaded(tb_data_loaded)
    );

    always_ff @(posedge tb_clk, negedge tb_n_rst) begin
        if (tb_n_rst == 1'b0) begin
            tb_d_plus <= 1'b1;
            tb_d_minus <= 1'b0;
        end else begin
            tb_d_plus <= tb_next_d_plus;
            tb_d_minus <= tb_next_d_minus;
        end
    end

    task send_bit;
        input data;
    begin
        if (data == 1'b1) begin
            tb_next_d_plus = tb_d_plus;
            tb_next_d_plus = tb_d_minus;
        end else begin
            tb_next_d_plus = ~tb_d_plus;
            tb_next_d_plus = ~tb_d_minus;
        end
        tb_d_orig = data;
        #NORM_DATA_PERIOD;
    end
    endtask

    task send_byte;
        input [7:0] data;
        integer i;
    begin
        for (i = 0; i < 8; i++) begin
            send_bit(data[i]);
        end
    end
    endtask

    task send_eop;
    begin
        tb_next_d_plus = '0;
        tb_next_d_minus = '0;
        tb_d_orig = '0;
        #(NORM_DATA_PERIOD * 2);
    end
    endtask

    task reset_dut;
    begin
        tb_n_rst = 1'b0;
        @(posedge tb_clk);
        @(posedge tb_clk);

        @(negedge tb_clk);

        tb_n_rst = 1'b1;

        @(posedge tb_clk);
        @(posedge tb_clk);
    end
    endtask 
    
    task check_output;
        input string check_tag;
    begin
        tb_check = 1'b1;
        tb_mismatch = 1'b0;

        assert(tb_expected_rx_packet_data == tb_rx_packet_data)
            $info("Test case %s correct for 'rx_packet_data', test num %0d", check_tag, tb_test_num);
        else begin
            $error("!!!!!!!!Test case %s incorrect for 'rx_packet_data', test num %0d!!!!!!!!!", check_tag, tb_test_num);
            tb_mismatch = 1'b1;
        end

        assert(tb_expected_rx_packet == tb_rx_packet)
            $info("Test case %s correct for 'rx_packet', test num %0d", check_tag, tb_test_num);
        else begin
            $error("!!!!!!!!Test case %s incorrect for 'rx_packet', test num %0d!!!!!!!!!", check_tag, tb_test_num);
            tb_mismatch = 1'b1;
        end

        assert(tb_expected_store_rx_packet == tb_store_rx_packet)
            $info("Test case %s correct for 'store_rx_packet', test num %0d", check_tag, tb_test_num);
        else begin
            $error("!!!!!!!!Test case %s incorrect for 'store_rx_packet', test num %0d!!!!!!!!!", check_tag, tb_test_num);
            tb_mismatch = 1'b1;
        end

        assert(tb_expected_r_error == tb_r_error)
            $info("Test case %s correct for 'r_error', test num %0d", check_tag, tb_test_num);
        else begin
            $error("!!!!!!!!Test case %s incorrect for 'r_error', test num %0d!!!!!!!!!", check_tag, tb_test_num);
            tb_mismatch = 1'b1;
        end

        assert(tb_expected_packet_done == tb_packet_done)
            $info("Test case %s correct for 'packet_done', test num %0d", check_tag, tb_test_num);
        else begin
            $error("!!!!!!!!Test case %s incorrect for 'packet_done', test num %0d!!!!!!!!!", check_tag, tb_test_num);
            tb_mismatch = 1'b1;
        end

        #(0.1);
        tb_check =1'b0;
    end
    endtask

    always begin
        tb_clk = 1'b0;
        #(CLK_PERIOD / 2);
        tb_clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    initial 
    begin
        tb_test_num                         = -1;
        tb_test_case                        = "TB Init";
        tb_check                            = 1'b0;
        tb_mismatch                         = 1'b0;
        tb_test_data                        = 8'b0;
        tb_expected_rx_packet               = 3'b0; 
        tb_expected_rx_packet_data          = 8'b0;
        tb_expected_store_rx_packet         = 1'b0;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;

        tb_n_rst                            = 1'b1; 
        tb_next_d_minus                     = 1'b1;
        tb_next_d_plus                      = 1'b0;
        tb_r_enable                         = 1'b0;

        // ************************************************************************
        // Test Case 1: Power on Reset
        // ************************************************************************
        tb_test_num += 1;
        tb_test_case = "Power_on_Reset";

        tb_test_data = 8'b0;

        tb_expected_rx_packet               = 3'b0; 
        tb_expected_rx_packet_data          = 8'b0;
        tb_expected_store_rx_packet         = 1'b0;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;

        send_byte(tb_test_data);
        reset_dut();
        check_output("Reset Check");
        #(CLK_PERIOD * 3);

        // ************************************************************************
        // Test Case 1: nominal data packet
        // ************************************************************************
        tb_test_num += 1;
        tb_test_case = "Nominal Data Transfet";

        reset_dut();
        tb_test_data = 8'b10000000;
        tb_expected_rx_packet               = 3'b0; 
        tb_expected_rx_packet_data          = 8'b0;
        tb_expected_store_rx_packet         = 1'b0;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        check_output("sync byte check");

        tb_test_data = 8'b11000011;
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_rx_packet_data          = 8'b0;
        tb_expected_store_rx_packet         = 1'b0;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        check_output("pid byte check");

        tb_test_data = 8'b00000000;
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_rx_packet_data          = 8'b0;
        tb_expected_store_rx_packet         = 1'b0;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        check_output("first byte 00");

        tb_test_data = 8'b00000001;
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_rx_packet_data          = 8'b00000001;
        tb_expected_store_rx_packet         = 1'b1;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        check_output("second byte 01");

        tb_test_data = 8'b00000010;
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_rx_packet_data          = 8'b00000010;
        tb_expected_store_rx_packet         = 1'b1;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        check_output("third byte 02");

        tb_test_data = 8'b00000011;
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_rx_packet_data          = 8'b00000011;
        tb_expected_store_rx_packet         = 1'b1;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        check_output("fourth byte 03");

        tb_test_data = 8'b11110111;
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_rx_packet_data          = 8'b0;
        tb_expected_store_rx_packet         = 1'b0;
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        check_output("crc first byte");

        tb_test_data = 8'b01011110;
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_rx_packet_data          = 8'b0;
        tb_expected_store_rx_packet         = 1'b0;
        tb_expected_packet_done             = 1'b1;
        tb_expected_r_error                 = 1'b0;
        send_byte(tb_test_data);
        send_eop();

        check_output("transfer done");



    end

endmodule