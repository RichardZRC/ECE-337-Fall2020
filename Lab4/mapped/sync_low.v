/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Mon Sep 21 10:17:59 2020
/////////////////////////////////////////////////////////////


module sync_low ( clk, n_rst, async_in, sync_out );
  input clk, n_rst, async_in;
  output sync_out;
  wire   sync_temp, n4, n5;

  DFFPOSX1 sync_temp_reg ( .D(n4), .CLK(clk), .Q(sync_temp) );
  DFFSR sync_out_reg ( .D(sync_temp), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        sync_out) );
  INVX1 U7 ( .A(n5), .Y(n4) );
  MUX2X1 U8 ( .B(sync_temp), .A(async_in), .S(n_rst), .Y(n5) );
endmodule

