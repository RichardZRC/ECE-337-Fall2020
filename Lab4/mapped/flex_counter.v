/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Tue Sep 22 11:02:51 2020
/////////////////////////////////////////////////////////////


module flex_counter ( clear, n_rst, clk, count_enable, rollover_val, count_out, 
        rollover_flag );
  input [2:0] rollover_val;
  output [2:0] count_out;
  input clear, n_rst, clk, count_enable;
  output rollover_flag;
  wire   n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40,
         n41, n42, n43, n44, n45;

  DFFSR \count_out_reg[0]  ( .D(n29), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[0]) );
  DFFSR \count_out_reg[2]  ( .D(n27), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[2]) );
  DFFSR \count_out_reg[1]  ( .D(n28), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[1]) );
  INVX1 U28 ( .A(n30), .Y(n29) );
  MUX2X1 U29 ( .B(count_out[0]), .A(n31), .S(n32), .Y(n30) );
  OAI22X1 U30 ( .A(n33), .B(count_out[0]), .C(n34), .D(clear), .Y(n31) );
  INVX1 U31 ( .A(n35), .Y(n28) );
  MUX2X1 U32 ( .B(n36), .A(n37), .S(count_out[1]), .Y(n35) );
  MUX2X1 U33 ( .B(n38), .A(n39), .S(count_out[2]), .Y(n27) );
  AOI21X1 U34 ( .A(n40), .B(n41), .C(n37), .Y(n39) );
  OAI21X1 U35 ( .A(count_out[0]), .B(n33), .C(n32), .Y(n37) );
  INVX1 U36 ( .A(n40), .Y(n33) );
  NAND2X1 U37 ( .A(n36), .B(count_out[1]), .Y(n38) );
  INVX1 U38 ( .A(n42), .Y(n36) );
  NAND3X1 U39 ( .A(count_out[0]), .B(n32), .C(n40), .Y(n42) );
  NOR2X1 U40 ( .A(rollover_flag), .B(clear), .Y(n40) );
  INVX1 U41 ( .A(n34), .Y(rollover_flag) );
  NAND3X1 U42 ( .A(n43), .B(n44), .C(n45), .Y(n34) );
  XOR2X1 U43 ( .A(n41), .B(rollover_val[1]), .Y(n45) );
  INVX1 U44 ( .A(count_out[1]), .Y(n41) );
  XNOR2X1 U45 ( .A(count_out[2]), .B(rollover_val[2]), .Y(n44) );
  XNOR2X1 U46 ( .A(count_out[0]), .B(rollover_val[0]), .Y(n43) );
  OR2X1 U47 ( .A(count_enable), .B(clear), .Y(n32) );
endmodule

