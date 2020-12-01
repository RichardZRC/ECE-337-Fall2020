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
    string tb_test_stage;

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

    //fifo signal
    reg tb_fifo_r_enable;
    reg [7:0] tb_fifo_r_data;
    reg tb_fifo_empty;
    reg tb_fifo_full;

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

    fifo fifo (
        .r_clk(tb_clk),
        .w_clk(tb_clk),
        .n_rst(tb_n_rst),
        .r_enable(tb_fifo_r_enable),
        .w_enable(tb_store_rx_packet),
        .w_data(tb_rx_packet_data),
        .r_data(tb_fifo_r_data),
        .empty(tb_fifo_empty),
        .full(tb_fifo_full)
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
            tb_next_d_minus = tb_d_minus;
        end else begin
            tb_next_d_plus = ~tb_d_plus;
            tb_next_d_minus = ~tb_d_minus;
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

    task send_idle;
    begin
        tb_next_d_plus = '1;
        tb_next_d_minus = '0;
        tb_d_orig = '0;
        #(NORM_DATA_PERIOD * 2);
    end
    endtask

    task reset_dut;
    begin
        tb_n_rst = 1'b0;
        tb_next_d_plus = 1'b1;
        tb_next_d_minus = 1'b0;
        @(posedge tb_clk);
        @(posedge tb_clk);

        @(negedge tb_clk);

        tb_n_rst = 1'b1;

        @(posedge tb_clk);
        @(posedge tb_clk);
    end
    endtask 

    task check_fifo;
        input [7:0] data;
        input string test_case;
        input integer byte_num;
    begin
        @(posedge tb_clk);
        tb_fifo_r_enable = 1'b1;
        @(posedge tb_clk);
        tb_fifo_r_enable = 1'b0;
        assert(tb_fifo_r_data == data)
            $info("Test %s is correct for %d byte", test_case, byte_num);
        else begin
            $error("!!!!!!!!Test %s is INCORRECT for %d byte!!!!!!!", test_case, byte_num);
        end
    end
    endtask 

    task check_fifo_empty;
        input string test_case;
    begin
        @(posedge tb_clk);
        assert(tb_fifo_empty == 1'b1) begin
            $info("fifo is empty for %s", test_case);
        end else begin
            $error("!!!!!!!fifo is NOT empty for %s!!!!!!!!", test_case);
        end
    end
    endtask
    
    task check_output;
        input string check_tag;
    begin
        tb_check = 1'b1;
        tb_mismatch = 1'b0;

        assert(tb_expected_rx_packet == tb_rx_packet)
            $info("Test case %s correct for 'rx_packet', test num %0d", check_tag, tb_test_num);
        else begin
            $error("!!!!!!!!Test case %s incorrect for 'rx_packet', test num %0d!!!!!!!!!", check_tag, tb_test_num);
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
        // Test Case 0: Power on Reset
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
        tb_test_case = "Nominal Data Transfer";

        reset_dut();
        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11000011;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000111;
        tb_test_stage = "sending first byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000001;
        tb_test_stage = "sending second byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000010;
        tb_test_stage = "sending third byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000011;
        tb_test_stage = "sending fourth byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11110111;
        tb_test_stage = "sending crc first byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01011110;
        tb_test_stage = "sending crc second byte byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_packet_done             = 1'b1;
        tb_expected_r_error                 = 1'b0;
        check_output("nomial data send");
        send_idle();

        #(NORM_DATA_PERIOD * 6);

        check_fifo(8'b00000111, "nominal data send", 1);
        check_fifo(8'b00000001, "nominal data send", 2);
        check_fifo(8'b00000010, "nominal data send", 3);
        check_fifo(8'b00000011, "nominal data send", 4);

        check_fifo_empty("nominal data send");


        // ************************************************************************
        // Test Case 2: IN token recognization
        // ************************************************************************
        #(NORM_DATA_PERIOD * 6);
        
        tb_test_num += 1;
        tb_test_case = "Recognize IN token";

        reset_dut();

        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01101001;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01110000;
        tb_test_stage = "sending IN token first byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000010;
        tb_test_stage = "sending IN token second byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b001; 
        tb_expected_packet_done             = 1'b1;
        tb_expected_r_error                 = 1'b0;
        check_output("IN token send");
        send_idle();
        

        // ************************************************************************
        // Test Case 3: OUT token recognization
        // ************************************************************************
        #(NORM_DATA_PERIOD * 6);
        
        tb_test_num += 1;
        tb_test_case = "Recognize OUT token";

        reset_dut();

        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11100001;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01110000;
        tb_test_stage = "sending OUT token first byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000010;
        tb_test_stage = "sending OUT token second byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b010; 
        tb_expected_packet_done             = 1'b1;
        tb_expected_r_error                 = 1'b0;     
        check_output("OUT token send");
        send_idle();

        // ************************************************************************
        // Test Case 4: ACK recognization
        // ************************************************************************
        #(NORM_DATA_PERIOD * 6);
        
        tb_test_num += 1;
        tb_test_case = "Recognize ACK";

        reset_dut();

        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11010010;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00001111;
        tb_test_stage = "sending random byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b100; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;     
        check_output("ACK send");
        send_idle();

        // ************************************************************************
        // Test Case 5: NACK recognization
        // ************************************************************************
        #(NORM_DATA_PERIOD * 6);
        
        tb_test_num += 1;
        tb_test_case = "Recognize NACK";

        reset_dut();

        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01011010;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11110000;
        tb_test_stage = "sending random byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b101; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;     
        check_output("NACK send");
        send_idle();

        // ************************************************************************
        // Test Case 6: Token with invalid address
        // ************************************************************************
        #(NORM_DATA_PERIOD * 6);
        
        tb_test_num += 1;
        tb_test_case = "Recognize invalid address IN token";

        reset_dut();

        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01101001;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11110000;
        tb_test_stage = "sending IN token first byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000010;
        tb_test_stage = "sending IN token second byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b001; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        check_output("invalid address IN token send");
        send_idle();

        // ************************************************************************
        // Test Case 7: Token with invalid endpoint number
        // ************************************************************************
        #(NORM_DATA_PERIOD * 6);
        
        tb_test_num += 1;
        tb_test_case = "Recognize invalid endpoint number IN token";

        reset_dut();

        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01101001;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b01110000;
        tb_test_stage = "sending IN token first byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000011;
        tb_test_stage = "sending IN token second byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b001; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        check_output("invalid endpoint number IN token send");
        send_idle();

        // // ************************************************************************
        // // Test Case 8: Data transfer with too-short data field
        // // ************************************************************************
        // #(NORM_DATA_PERIOD * 6);
        // tb_test_num += 1;
        // tb_test_case = "too-short Data Transfer";

        // reset_dut();
        // tb_test_data = 8'b10000000;
        // tb_test_stage = "sending sync byte";
        // send_byte(tb_test_data);

        // tb_test_data = 8'b11000011;
        // tb_test_stage = "sending pid byte";
        // send_byte(tb_test_data);

        // tb_test_data = 8'b00000111;
        // tb_test_stage = "sending first byte";
        // send_byte(tb_test_data);

        // tb_test_data = 8'b00000001;
        // tb_test_stage = "sending second byte";
        // send_byte(tb_test_data);

        // send_eop();
        // tb_expected_rx_packet               = 3'b011; 
        // tb_expected_packet_done             = 1'b0;
        // tb_expected_r_error                 = 1'b1;
        // check_output("too-short data send");
        // send_idle();

        // #(NORM_DATA_PERIOD * 6);

        // check_fifo_empty("too-short data send");

        // ************************************************************************
        // Test Case 9: Premature EOP error
        // ************************************************************************
        #(NORM_DATA_PERIOD * 6);
        tb_test_num += 1;
        tb_test_case = "premature EOP";

        reset_dut();
        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11000011;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000111;
        tb_test_stage = "sending first byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000001;
        tb_test_stage = "sending second byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b00000111;
        tb_test_stage = "sending first byte";
        send_byte(tb_test_data);

        send_bit(1'b1);
        send_eop();
        tb_expected_rx_packet               = 3'b011; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b1;
        check_output("premature eop send");
        send_idle();

        //TODO: check fifo

        // #(NORM_DATA_PERIOD * 6);

        // check_fifo_empty("premature eop send");        

        // ************************************************************************
        // Test Case 10: Incorrect sync byte
        // ************************************************************************

        #(NORM_DATA_PERIOD * 6);
        tb_test_num += 1;
        tb_test_case = "invalid sync byte";

        reset_dut();
        tb_test_data = 8'b10000001;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        //TODO: check fifo

        send_eop();
        tb_expected_rx_packet               = 3'b000; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b1;
        check_output("invalid sync send");
        send_idle();

        // ************************************************************************
        // Test Case 11: invaid pid byte
        // ************************************************************************
        
        #(NORM_DATA_PERIOD * 6);
        tb_test_num += 1;
        tb_test_case = "invalid pid byte";

        reset_dut();
        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11000111;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b000; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b1;
        check_output("invalid pid send");
        send_idle();

        // ************************************************************************
        // Test Case 12: unsupported pid byte
        // ************************************************************************
        
        #(NORM_DATA_PERIOD * 6);
        tb_test_num += 1;
        tb_test_case = "unsupported pid byte";

        reset_dut();
        tb_test_data = 8'b10000000;
        tb_test_stage = "sending sync byte";
        send_byte(tb_test_data);

        tb_test_data = 8'b11110000;
        tb_test_stage = "sending pid byte";
        send_byte(tb_test_data);

        send_eop();
        tb_expected_rx_packet               = 3'b110; 
        tb_expected_packet_done             = 1'b0;
        tb_expected_r_error                 = 1'b0;
        check_output("unsupported pid send");
        send_idle();





    end

endmodule