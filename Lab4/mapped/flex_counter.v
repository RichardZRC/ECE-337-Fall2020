/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Wed Sep 23 05:38:07 2020
/////////////////////////////////////////////////////////////


module flex_counter ( clear, n_rst, clk, count_enable, rollover_val, count_out, 
        rollover_flag );
  input [2:0] rollover_val;
  output [2:0] count_out;
  input clear, n_rst, clk, count_enable;
  output rollover_flag;
  wire   n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28,
         n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42,
         n43, n44, n45, n46, n47, n48, n49, n50, n51, n52;

  DFFSR \count_out_reg[0]  ( .D(n52), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[0]) );
  DFFSR \count_out_reg[2]  ( .D(n50), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[2]) );
  DFFSR \count_out_reg[1]  ( .D(n51), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[1]) );
  DFFSR rollover_flag_reg ( .D(n49), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        rollover_flag) );
  INVX2 U7 ( .A(count_out[2]), .Y(n15) );
  INVX2 U8 ( .A(n40), .Y(n16) );
  INVX2 U9 ( .A(n41), .Y(n17) );
  INVX2 U10 ( .A(count_out[1]), .Y(n18) );
  INVX2 U11 ( .A(n31), .Y(n19) );
  INVX2 U12 ( .A(count_out[0]), .Y(n20) );
  INVX2 U13 ( .A(clear), .Y(n21) );
  INVX2 U14 ( .A(n29), .Y(n22) );
  INVX2 U15 ( .A(rollover_val[2]), .Y(n23) );
  INVX2 U16 ( .A(rollover_val[1]), .Y(n24) );
  INVX2 U17 ( .A(rollover_val[0]), .Y(n25) );
  OAI21X1 U18 ( .A(n26), .B(n27), .C(n28), .Y(n49) );
  NAND2X1 U19 ( .A(rollover_flag), .B(n29), .Y(n28) );
  NAND3X1 U20 ( .A(n30), .B(n31), .C(n17), .Y(n27) );
  XNOR2X1 U21 ( .A(n32), .B(n15), .Y(n30) );
  OAI21X1 U22 ( .A(rollover_val[0]), .B(rollover_val[1]), .C(rollover_val[2]), 
        .Y(n32) );
  NAND3X1 U23 ( .A(n22), .B(n33), .C(n34), .Y(n26) );
  XNOR2X1 U24 ( .A(n18), .B(n35), .Y(n34) );
  XNOR2X1 U25 ( .A(n24), .B(rollover_val[0]), .Y(n35) );
  NAND3X1 U26 ( .A(n24), .B(n23), .C(n25), .Y(n33) );
  OAI21X1 U27 ( .A(n36), .B(n37), .C(n38), .Y(n50) );
  OAI21X1 U28 ( .A(n39), .B(n40), .C(count_out[2]), .Y(n38) );
  NOR2X1 U29 ( .A(count_out[1]), .B(n41), .Y(n39) );
  NAND2X1 U30 ( .A(n17), .B(count_out[1]), .Y(n37) );
  NAND3X1 U31 ( .A(n22), .B(n15), .C(count_out[0]), .Y(n36) );
  OAI21X1 U32 ( .A(n16), .B(n18), .C(n42), .Y(n51) );
  NAND3X1 U33 ( .A(n21), .B(n18), .C(n43), .Y(n42) );
  NOR2X1 U34 ( .A(n29), .B(n44), .Y(n43) );
  OAI21X1 U35 ( .A(count_out[0]), .B(n41), .C(n22), .Y(n40) );
  NAND2X1 U36 ( .A(n45), .B(n21), .Y(n41) );
  OAI21X1 U37 ( .A(n20), .B(n22), .C(n46), .Y(n52) );
  NAND3X1 U38 ( .A(n22), .B(n21), .C(n44), .Y(n46) );
  NAND2X1 U39 ( .A(count_out[0]), .B(n45), .Y(n44) );
  NAND3X1 U40 ( .A(n47), .B(n19), .C(n48), .Y(n45) );
  XNOR2X1 U41 ( .A(rollover_val[2]), .B(count_out[2]), .Y(n48) );
  XNOR2X1 U42 ( .A(count_out[0]), .B(n25), .Y(n31) );
  XNOR2X1 U43 ( .A(rollover_val[1]), .B(count_out[1]), .Y(n47) );
  NOR2X1 U44 ( .A(clear), .B(count_enable), .Y(n29) );
endmodule

