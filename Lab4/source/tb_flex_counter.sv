`timescale 1ns / 10ps

module tb_flex_counter();

    // Define local parameters used by the test bench
    localparam  CLK_PERIOD    = 2.5;
    localparam  FF_SETUP_TIME = 0.190;
    localparam  FF_HOLD_TIME  = 0.100;
    localparam  CHECK_DELAY   = (CLK_PERIOD - FF_SETUP_TIME); // Check right before the setup time starts

    localparam  INACTIVE_VALUE     = 1'b0;
    localparam  RESET_OUTPUT_VALUE = 1'b0;

    localparam  NUM_CNT_BITS = 3;
    localparam  MAX_CNT_BITS = NUM_CNT_BITS - 1; 

    // Declare DUT portmap signals
    reg tb_clk;
    reg tb_n_rst;
    reg tb_clear;
    reg [MAX_CNT_BITS : 0] tb_count_out;
    reg [MAX_CNT_BITS : 0] tb_rollover_val;
    reg tb_rollover_flag;
    reg tb_count_enable;
    reg [MAX_CNT_BITS : 0] tb_expected_count_out;
    reg tb_expected_rollover_flag;



    // Declare test bench signals
    integer tb_test_num;
    string tb_test_case;
    integer tb_continuous_counting_num;
    string tb_continuous_counting_tag;

  // Clock generation block
    always
    begin
    // Start with clock low to avoid false rising edge events at t=0
    tb_clk = 1'b0;
    // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    tb_clk = 1'b1;
    // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
    #(CLK_PERIOD/2.0);
    end

    // Task for standard DUT reset procedure
    task reset_dut;
        begin
        // Activate the reset
        tb_n_rst = 1'b0;

        // Maintain the reset for more than one cycle
        @(posedge tb_clk);
        @(posedge tb_clk);

        // Wait until safely away from rising edge of the clock before releasing
        @(negedge tb_clk);
        tb_n_rst = 1'b1;

        // Leave out of reset for a couple cycles before allowing other stimulus
        // Wait for negative clock edges, 
        // since inputs to DUT should normally be applied away from rising clock edges
        @(negedge tb_clk);
        @(negedge tb_clk);
        end
    endtask

    task check_output_count_out;
        input logic [MAX_CNT_BITS : 0] expected_count_out;
        input string check_tag;
        begin
            if (tb_count_out == expected_count_out) begin
                $info("Correct count_out output %s during %s test case", check_tag, tb_test_case);
            end
            else begin
                $error("Incorrect count_out output %s during %s test case", check_tag, tb_test_case);
            end
        end
    endtask

    task check_output_rollover_flag;
        input logic expected_rollover_flag;
        input string check_tag;
        begin
            if (tb_rollover_flag == expected_rollover_flag) begin
                $info("Correct rollover_flag output %s during %s test case", check_tag, tb_test_case);
            end
            else begin
                $error("Incorrect rollover_flag output %s during %s test case", check_tag, tb_test_case);
            end
        end
    endtask

    task normal_clear;
        begin
            tb_clear = 1'b1;
            #(CLK_PERIOD);
            tb_clear = 1'b0;
        end
    endtask

    flex_counter DUT (.clk(tb_clk), .n_rst(tb_n_rst), .clear(tb_clear),
     .count_out(tb_count_out), .rollover_flag(tb_rollover_flag), .rollover_val(tb_rollover_val), .count_enable(tb_count_enable));

    initial begin
        tb_n_rst = 1'b1;
        tb_count_enable = 1'b0;
        tb_clear = 1'b0;
        tb_rollover_val = 2'b10;
        tb_test_case = "Test bench initializaton";
        tb_test_num = 0;

        #(0.1);

        // ************************************************************************
        // Test Case 1: Power-on Reset of the DUT
        // ************************************************************************
        tb_test_num = tb_test_num + 1;
        tb_test_case = "Power on Reset";
        // Note: Do not use reset task during reset test case since we need to specifically check behavior during reset
        // Wait some time before applying test case stimulus
        #(0.1);
        tb_rollover_val = 1'b1;
        tb_n_rst  = 1'b0;    // Activate reset
        
        // Wait for a bit before checking for correct functionality
        #(CLK_PERIOD * 0.5);

        // Check that internal state was correctly reset
        check_output_count_out(1'b0, "after reset applied");
        check_output_rollover_flag(1'b0, "after reset applied");
        
        // Check that the reset value is maintained during a clock cycle
        #(CLK_PERIOD);
        check_output_count_out(1'b0, "after clock cycle while in reset");
        check_output_rollover_flag(1'b0, "after clock cycle while in reset");
        
        // Release the reset away from a clock edge
        @(posedge tb_clk);
        #(2 * FF_HOLD_TIME);
        tb_n_rst  = 1'b1;   // Deactivate the chip reset
        #0.1;
        // Check that internal state was correctly keep after reset release
        check_output_count_out(1'b0, "after reset was released");
        check_output_rollover_flag(1'b0, "after reset was released");


        // ************************************************************************
        // Test Case 2: Rollover for a value that is not a power of 2
        // ************************************************************************
        @(negedge tb_clk)
        tb_test_case = "Rollover for a value that is not a power of 2";
        tb_test_num = tb_test_num + 1;

        tb_clear = 1'b0;
        tb_count_enable = 1'b0;
        tb_rollover_val = 2'd3;
        reset_dut();

        tb_count_enable = 1'b1;

        @(posedge tb_clk);
        tb_expected_count_out = 2'd1;
        tb_expected_rollover_flag = 1'b0;
        #(CHECK_DELAY);
        check_output_count_out(tb_expected_count_out, "at count 1");
        check_output_rollover_flag(tb_expected_rollover_flag, "at count 1");

        @(posedge tb_clk);
        tb_expected_count_out = 2'd2;
        tb_expected_rollover_flag = 1'b0;
        #(CHECK_DELAY);
        check_output_count_out(tb_expected_count_out, "at count 2");
        check_output_rollover_flag(tb_expected_rollover_flag, "at count 2");

        @(posedge tb_clk);
        tb_expected_count_out = 2'd3;
        tb_expected_rollover_flag = 1'b1;
        #(CHECK_DELAY);
        check_output_count_out(tb_expected_count_out, "at rollover value");
        check_output_rollover_flag(tb_expected_rollover_flag, "at rollover value");

        @(posedge tb_clk)
        tb_expected_count_out = 1'b1;
        tb_expected_rollover_flag = 1'b0;
        #(CHECK_DELAY)
        check_output_count_out(tb_expected_count_out, "after rollover");
        check_output_rollover_flag(1'b0, "after rollover");


        // ************************************************************************
        // Test Case 3: Continous counting
        // ************************************************************************
        @(negedge tb_clk)
        tb_test_case = "Continuous counting";
        tb_test_num = tb_test_num + 1;

        tb_clear = 1'b0;
        tb_count_enable = 1'b0;
        tb_rollover_val = 3'd7;
        reset_dut();

        tb_count_enable = 1'b1;
        tb_expected_count_out = 1'b0;
        tb_expected_rollover_flag = 1'b0;

        for (tb_continuous_counting_num = 0; tb_continuous_counting_num < 10; tb_continuous_counting_num = tb_continuous_counting_num + 1) begin
            $sformat(tb_continuous_counting_tag, "for continuous counting iteration %d", tb_continuous_counting_num);
            @(posedge tb_clk);
            if ((tb_expected_count_out != 0) && (tb_expected_count_out % 7 == 0)) begin
                tb_expected_count_out = 1'b1; 
                tb_expected_rollover_flag = 1'b0;
            end
            else begin
                tb_expected_count_out = tb_expected_count_out + 1;
                if (tb_expected_count_out % 7 == 0) begin
                    tb_expected_rollover_flag = 1'b1;
                end
            end

            #(1);
            check_output_count_out(tb_expected_count_out, tb_continuous_counting_tag);
            check_output_rollover_flag(tb_expected_rollover_flag, tb_continuous_counting_tag);
        end

        // ************************************************************************
        // Test Case 4: discontinous counting
        // ************************************************************************
        @(negedge tb_clk)
        tb_test_case = "discontinuous counting";
        tb_test_num = tb_test_num + 1;

        tb_clear = 1'b0;
        tb_count_enable = 1'b0;
        tb_rollover_val = 3'd7;
        reset_dut();

        tb_count_enable = 1'b1;
        tb_expected_count_out = 1'b0;
        tb_expected_rollover_flag = 1'b0;

        for (tb_continuous_counting_num = 0; tb_continuous_counting_num < 10; tb_continuous_counting_num = tb_continuous_counting_num + 1) begin
            $sformat(tb_continuous_counting_tag, "for continuous counting iteration %d", tb_continuous_counting_num);
            @(posedge tb_clk);
            if ((tb_expected_count_out != 0) && (tb_expected_count_out % 7 == 0)) begin
                tb_expected_count_out = 1'b1; 
                tb_expected_rollover_flag = 1'b0;
            end
            else begin
                tb_expected_count_out = tb_expected_count_out + 1;
                if (tb_expected_count_out % 7 == 0) begin
                    tb_expected_rollover_flag = 1'b1;
                end
            end

            if (tb_expected_count_out == 3) begin
                #(1);
                tb_count_enable = 1'b0;
                @(posedge tb_clk);
                #(1)
                check_output_count_out(tb_expected_count_out, "disabled count_out 1");
                check_output_rollover_flag(tb_expected_rollover_flag, "disabled rollover flag 1");

                @(posedge tb_clk);
                #(1)
                check_output_count_out(tb_expected_count_out, "disabled count_out 2");
                check_output_rollover_flag(tb_expected_rollover_flag, "disabled rollover flag 2");

                tb_count_enable = 1'b1;
            end

            else begin
                #(1);
                check_output_count_out(tb_expected_count_out, tb_continuous_counting_tag);
                check_output_rollover_flag(tb_expected_rollover_flag, tb_continuous_counting_tag);
            end
        end


    end


endmodule
