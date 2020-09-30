/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Mon Sep 28 10:53:25 2020
/////////////////////////////////////////////////////////////


module pts_sr_4_msb ( clk, n_rst, shift_enable, load_enable, parallel_in, 
        serial_out );
  input [3:0] parallel_in;
  input clk, n_rst, shift_enable, load_enable;
  output serial_out;

  tri   clk;
  tri   n_rst;
  tri   shift_enable;
  tri   load_enable;
  tri   [3:0] parallel_in;
  tri   serial_out;

  flex_pts_sr CORE ( .clk(clk), .n_rst(n_rst), .parallel_in(parallel_in), 
        .shift_enable(shift_enable), .load_enable(load_enable), .serial_out(
        serial_out) );
endmodule

