/**
 * File name:	tb_ahb_lite_fir_filter.sv
 * Created:	04/02/2020
 * Author:	Weili
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	test bench file for ahb lite fir filter acclerator
 */

`timescale 1ns / 10ps

module tb_ahb_lite_fir_filter ();

    // Copied from tb_ahb_lite_slave.sv
    localparam BUS_DELAY  = 800ps; // Based on FF propagation delay

    // Sizing related constants
    localparam DATA_WIDTH      = 2;
    localparam ADDR_WIDTH      = 4;
    localparam DATA_WIDTH_BITS = DATA_WIDTH * 8;
    localparam DATA_MAX_BIT    = DATA_WIDTH_BITS - 1;
    localparam ADDR_MAX_BIT    = ADDR_WIDTH - 1;

    // Define our address mapping scheme via constants
    localparam ADDR_STATUS      = 4'd0;
    localparam ADDR_STATUS_BUSY = 4'd0;
    localparam ADDR_STATUS_ERR  = 4'd1;
    localparam ADDR_RESULT      = 4'd2;
    localparam ADDR_SAMPLE      = 4'd4;
    localparam ADDR_COEF_START  = 4'd6;  // F0
    localparam ADDR_COEF_SET    = 4'd14; // Coeff Set Confirmation

    // AHB-Lite-Slave reset value constants
    // Student TODO: Update these based on the reset values for your config registers
    localparam RESET_COEFF  = '0;
    localparam RESET_SAMPLE = '0;

    //*****************************************************************************
    // Declare TB Signals (Bus Model Controls)
    //*****************************************************************************
    // Testing setup signals
    logic                      tb_enqueue_transaction;
    logic                      tb_transaction_write;
    logic                      tb_transaction_fake;
    logic [ADDR_MAX_BIT:0]     tb_transaction_addr;
    logic [DATA_MAX_BIT:0]     tb_transaction_data;
    logic                      tb_transaction_error;
    logic [2:0]                tb_transaction_size;
    // Testing control signal(s)
    logic    tb_enable_transactions;
    integer  tb_current_transaction_num;
    logic    tb_current_transaction_error;
    logic    tb_model_reset;
    string   tb_test_case;
    integer  tb_test_case_num;
    logic [DATA_MAX_BIT:0] tb_test_data;
    string                 tb_check_tag;
    string                 tb_ignore_tag;
    string                 tb_task_name = "";
    logic                  tb_mismatch;
    logic                  tb_check;

    //*****************************************************************************
    // AHB-Lite-Slave side signals
    //*****************************************************************************
    logic                  tb_hsel;
    logic [1:0]            tb_htrans;
    logic [ADDR_MAX_BIT:0] tb_haddr;
    logic [2:0]            tb_hsize;
    logic                  tb_hwrite;
    logic [DATA_MAX_BIT:0] tb_hwdata;
    logic [DATA_MAX_BIT:0] tb_hrdata;
    logic                  tb_hresp;

    // Copied from tb_fir_filter.sv
    // Define local constants
	localparam NUM_VAL_BITS	= 16;
	localparam MAX_VAL_BIT	= NUM_VAL_BITS - 1;
	localparam CHECK_DELAY	= 1ns;
	localparam CLK_PERIOD		= 10ns;
	
	// Test coefficient constants
	localparam COEFF1 		= 16'h8000; // 1.0
	localparam COEFF_5 		= 16'h4000; // 0.5
	localparam COEFF_25 	= 16'h2000; // 0.25
	localparam COEFF_125 	= 16'h1000; // 0.125
	localparam COEFF0  		= 16'h0000; // 0.0
	
	// Define our custom test vector type
	typedef struct
	{
		reg [MAX_VAL_BIT:0] coeffs[3:0];
		reg [MAX_VAL_BIT:0] samples[3:0];
		reg [MAX_VAL_BIT:0] results[3:0];
		reg errors[3:0];
	} testVector;
	
	// Test bench dut port signals
	reg tb_clk;
	reg tb_n_rst;
	
	// Test bench verification signals
	integer tb_test_sample_num;
	integer tb_std_test_case;
	testVector tb_test_vectors[];
	testVector tb_test_con_vectors[];
	testVector tb_empty_vector;
	
	task reset_dut;
	begin
		// Activate the design's reset (does not need to be synchronize with clock)
		tb_n_rst = 1'b0;
		
		// Wait for a couple clock cycles
		@(posedge tb_clk);
		@(posedge tb_clk);
		
		// Release the reset
		@(negedge tb_clk);
		tb_n_rst = 1;
		
		// Wait for a while before activating the design
		@(posedge tb_clk);
		@(posedge tb_clk);
	end
	endtask
	
	// Clock gen block
	always
	begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end

    //*****************************************************************************
    // Bus Model Instance
    //*****************************************************************************
    ahb_lite_bus BFM (.clk(tb_clk),
                    // Testing setup signals
                    .enqueue_transaction(tb_enqueue_transaction),
                    .transaction_write(tb_transaction_write),
                    .transaction_fake(tb_transaction_fake),
                    .transaction_addr(tb_transaction_addr),
                    .transaction_data(tb_transaction_data),
                    .transaction_error(tb_transaction_error),
                    .transaction_size(tb_transaction_size),
                    // Testing controls
                    .model_reset(tb_model_reset),
                    .enable_transactions(tb_enable_transactions),
                    .current_transaction_num(tb_current_transaction_num),
                    .current_transaction_error(tb_current_transaction_error),
                    // AHB-Lite-Slave Side
                    .hsel(tb_hsel),
                    .htrans(tb_htrans),
                    .haddr(tb_haddr),
                    .hsize(tb_hsize),
                    .hwrite(tb_hwrite),
                    .hwdata(tb_hwdata),
                    .hrdata(tb_hrdata),
                    .hresp(tb_hresp));

    // ************************************************************************
    // DUT Instance
    // ************************************************************************
    ahb_lite_fir_filter u_ahb_lite_fir_filter(
    	.clk    (tb_clk    ),
        .n_rst  (tb_n_rst  ),
        .hsel   (tb_hsel   ),
        .haddr  (tb_haddr  ),
        .hsize  (tb_hsize  ),
        .htrans (tb_htrans ),
        .hwrite (tb_hwrite ),
        .hwdata (tb_hwdata ),
        .hrdata (tb_hrdata ),
        .hresp  (tb_hresp  )
    );

    //*****************************************************************************
    // Bus Model Usage Related TB Tasks
    //*****************************************************************************
    // Task to pulse the reset for the bus model
    task reset_model;
    begin
        tb_model_reset = 1'b1;
        #(0.1);
        tb_model_reset = 1'b0;
        end
    endtask

    // Task to enqueue a new transaction
    task enqueue_transaction;
        input logic for_dut;
        input logic write_mode;
        input logic [ADDR_MAX_BIT:0] address;
        input logic [DATA_MAX_BIT:0] data;
        input logic expected_error;
        input logic size;
    begin
        // Make sure enqueue flag is low (will need a 0->1 pulse later)
        tb_enqueue_transaction = 1'b0;
        #0.1ns;

        // Setup info about transaction
        tb_transaction_fake  = ~for_dut;
        tb_transaction_write = write_mode;
        tb_transaction_addr  = address;
        tb_transaction_data  = data;
        tb_transaction_error = expected_error;
        tb_transaction_size  = {2'b00,size};

        // Pulse the enqueue flag
        tb_enqueue_transaction = 1'b1;
        #0.1ns;
        tb_enqueue_transaction = 1'b0;
        end
    endtask

    // Task to wait for multiple transactions to happen
    task execute_transactions;
        input integer num_transactions;
        integer wait_var;
    begin
        // Activate the bus model
        tb_enable_transactions = 1'b1;
        @(posedge tb_clk);

        // Process the transactions (all but last one overlap 1 out of 2 cycles
        for(wait_var = 0; wait_var < num_transactions; wait_var++) begin
            @(posedge tb_clk);
        end

        // Run out the last one (currently in data phase)
        @(posedge tb_clk);

        // Turn off the bus model
        @(negedge tb_clk);
        tb_enable_transactions = 1'b0;
        end
    endtask

    // ************************************************************************
    // DUT Related task
    // ************************************************************************
    
    task config_fir_filter;
        input [MAX_VAL_BIT:0] coeffs [3:0];
    begin
        // Enqueue
        enqueue_transaction(1'b1, 1'b1, ADDR_COEF_START, coeffs[0], 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b1, ADDR_COEF_START + 2, coeffs[1], 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b1, ADDR_COEF_START + 4, coeffs[2], 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b1, ADDR_COEF_START + 6, coeffs[3], 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b1, ADDR_COEF_SET, 16'd1, 1'b0, 1'b0);  // Signify new coefficients
        execute_transactions(5);
        wait_for_loading_coeffs;
    end
    endtask

    // Polling to wait for coeffs loading
    task wait_for_loading_coeffs;
    begin
        tb_task_name = "Loading coeffs";
        //while (1) begin
        //    tb_ignore_tag = "Ignore waiting for coeffs";
        //    enqueue_transaction(1'b1, 1'b0, ADDR_COEF_SET, 16'd1, 1'b0, 1'b0);
        //    execute_transactions(1);
        //    if (tb_hrdata != 16'd1)
        //        break;
        //end
	    repeat (25) @(negedge tb_clk);
        tb_ignore_tag = "Not-ignore";
        tb_task_name = "";
    end
    endtask

    // Send single packet
    task send_single_sample;
        input [MAX_VAL_BIT:0] sample;
    begin
        tb_task_name = "send sample";
        tb_ignore_tag = "Not-ignore";
        enqueue_transaction(1'b1, 1'b1, ADDR_SAMPLE, sample, 1'b0, 1'b1);
        execute_transactions(1);
        tb_task_name = "";

    end
    endtask

    // Polling to wait for fir calculation
    task wait_for_fir;
    begin
        tb_task_name = "wait for fir";
        tb_ignore_tag = "Ignore waiting for fir";
        // extra waiting just in case
        //enqueue_transaction(1'b1, 1'b0, ADDR_STATUS, 16'd1, 1'b0, 1'b1);
        //execute_transactions(1);
        //while (1) begin
        //    tb_ignore_tag = "Ignore waiting for fir";
        //    enqueue_transaction(1'b1, 1'b0, ADDR_STATUS, 16'd1, 1'b0, 1'b1);
        //    execute_transactions(1);
        //    if (tb_hrdata[0] != 1'b1)
        //        break;
        //end
        repeat (50) @(negedge tb_clk);
	tb_ignore_tag = "Not-ignore";
        tb_task_name = "";

    end
    endtask

    // Check for result and compare
    task check_result;
        input [MAX_VAL_BIT:0] expected_result;
        input expected_error;
    begin
        tb_ignore_tag = "Not-ignore";
        tb_task_name = "check result";
        enqueue_transaction(1'b1, 1'b0, ADDR_RESULT, expected_result, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_STATUS_ERR, {7'b0, expected_error}, 1'b0, 1'b0);
        execute_transactions(1);
        tb_task_name = "";

    end
    endtask

    // Task for sending/handling a sample
	task test_sample;
		// Test inputs
		input [MAX_VAL_BIT:0] sample_value;
		
		// Expected outputs
		input [MAX_VAL_BIT:0] expected_fir_out;
		input expected_err;
	begin
        send_single_sample(sample_value);
        wait_for_fir;
        check_result(expected_fir_out, expected_err);
	end
	endtask
	
	
	// Task for a test case
	task test_stream;
		input testVector tv;
	
		//input [MAX_VAL_BIT:0] coeffs [3:0];
		//input [MAX_VAL_BIT:0] samples [3:0];
		
		//input [MAX_VAL_BIT:0] expected_outs [3:0];
		//input expected_errs [3:0];
		
		integer s;
	begin
		// Reset the design
		// tb_test_case_num += 1;
		reset_dut;
		
		// Load the set of coefficients
		config_fir_filter(tv.coeffs);
		
		// Send the stream of samples provided
		tb_test_sample_num = 0;
		for(s = 0; s < 4; s++)
		begin
            tb_test_sample_num = s;
			test_sample(tv.samples[s], tv.results[s], tv.errors[s]);
		end
	end
	endtask

	// Task for a test case
	task test_stream_ncoeffs;
		input testVector tv;
	
		//input [MAX_VAL_BIT:0] coeffs [3:0];
		//input [MAX_VAL_BIT:0] samples [3:0];
		
		//input [MAX_VAL_BIT:0] expected_outs [3:0];
		//input expected_errs [3:0];
		
		integer s;
	begin		
		// Send the stream of samples provided
		tb_test_sample_num = 0;
		for(s = 0; s < 4; s++)
		begin
            tb_test_sample_num = s;
			test_sample(tv.samples[s], tv.results[s], tv.errors[s]);
		end
	end
	endtask

    //*****************************************************************************
    //*****************************************************************************
    // Main TB Process
    //*****************************************************************************
    //*****************************************************************************
    initial begin
        // Initialize Test Case Navigation Signals
        tb_test_case       = "Initilization";
        tb_test_case_num   = -1;
        tb_test_data       = '0;
        tb_check_tag       = "N/A";
        tb_check           = 1'b0;
        tb_mismatch        = 1'b0;
        // Initialize all of the directly controled DUT inputs
        tb_n_rst          = 1'b1;
        // Initialize all of the bus model control inputs
        tb_model_reset          = 1'b0;
        tb_enable_transactions  = 1'b0;
        tb_enqueue_transaction  = 1'b0;
        tb_transaction_write    = 1'b0;
        tb_transaction_fake     = 1'b0;
        tb_transaction_addr     = '0;
        tb_transaction_data     = '0;
        tb_transaction_error    = 1'b0;
        tb_transaction_size     = 3'd0;

        // Populate the test vector array to use
		tb_test_vectors = new[3];
		// Test case 0
		tb_test_vectors[0].coeffs		= {{COEFF_5}, {COEFF1}, {COEFF1}, {COEFF_5}};
		tb_test_vectors[0].samples	= {16'd100, 16'd100, 16'd100, 16'd100};
		tb_test_vectors[0].results	= {16'd0, 16'd50, 16'd50 ,16'd50};
		tb_test_vectors[0].errors		= {1'b0, 1'b0, 1'b0, 1'b0};
		// Test case 1
		tb_test_vectors[1].coeffs		= tb_test_vectors[0].coeffs;
		tb_test_vectors[1].samples	= {16'd1000, 16'd1000, 16'd100, 16'd100};
		tb_test_vectors[1].results	= {16'd450, 16'd500, 16'd50 ,16'd50};
		tb_test_vectors[1].errors		= {1'b0, 1'b0, 1'b0, 1'b0};
		// Test case 2: Data overflow in state CONV_SUB_2
		tb_test_vectors[2].coeffs		= tb_test_vectors[0].coeffs;
		tb_test_vectors[2].samples	= {16'd1000, 16'd1000, 16'd0, 16'hffff};
		tb_test_vectors[2].results	= {16'd33267, 16'hffff, 16'hffff ,16'h7fff};
		tb_test_vectors[2].errors		= {1'b0, 1'b1, 1'b0, 1'b0};

        // Wait some time before starting first test case
        #(0.1);

        // Clear the bus model
        reset_model();

        //*****************************************************************************
        // Power-on-Reset Test Case
        //*****************************************************************************
        // Update Navigation Info
        tb_test_case     = "Power-on-Reset";
        tb_test_case_num = tb_test_case_num + 1;

        // Reset the DUT
        reset_dut();

        // Check regs
        enqueue_transaction(1'b1, 1'b0, ADDR_STATUS, 16'b0, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_RESULT, 16'b0, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_SAMPLE, 16'b0, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_COEF_START, 16'b0, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_COEF_START + 2, 16'b0, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_COEF_START + 4, 16'b0, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_COEF_START + 6, 16'b0, 1'b0, 1'b1);
        enqueue_transaction(1'b1, 1'b0, ADDR_COEF_SET, 16'b0, 1'b0, 1'b0);
        execute_transactions(8);

        // Give some visual spacing between check and next test case start
        #(CLK_PERIOD * 3);

        // ************************************************************************
        // Test Case 1: Standard 4 sample test cases
        // ************************************************************************
        // Update Navigation Info
        tb_test_case     = "Standard 4 sample test cases";
        tb_test_case_num = tb_test_case_num + 1;

        // Reset the DUT
        reset_dut();

        // Standard 4 sample test cases
		for(tb_std_test_case = 0; tb_std_test_case < tb_test_vectors.size(); tb_std_test_case++)
		begin
			test_stream(tb_test_vectors[tb_std_test_case]);
		end

        // ************************************************************************
        // Test Case 2: Consecutive packets
        // ************************************************************************
        tb_test_case_num += 1;
		tb_test_case = "Consecutive packets";

		// Reset DUT
		reset_dut;

		// Specify test vectors
		tb_test_con_vectors = new[2];

		// Test case 0
		tb_test_con_vectors[0].coeffs		= {{COEFF_5}, {COEFF1}, {COEFF1}, {COEFF_5}};
		tb_test_con_vectors[0].samples		= {16'd100, 16'd100, 16'd100, 16'd100};
		tb_test_con_vectors[0].results		= {16'd0, 16'd50, 16'd50 ,16'd50};
		tb_test_con_vectors[0].errors		= {1'b0, 1'b0, 1'b0, 1'b0};
		// Test case 1
		tb_test_con_vectors[1].coeffs		= tb_test_con_vectors[0].coeffs;
		tb_test_con_vectors[1].samples		= {16'd500, 16'd400, 16'd300, 16'd200};
		tb_test_con_vectors[1].results		= {16'd50, 16'd50, 16'd0 ,16'd50};
		tb_test_con_vectors[1].errors		= {1'b0, 1'b0, 1'b0, 1'b0};

		test_stream(tb_test_con_vectors[0]);
		test_stream_ncoeffs(tb_test_con_vectors[1]);
    end
endmodule
