/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Wed Sep 30 06:30:39 2020
/////////////////////////////////////////////////////////////


module moore ( clk, n_rst, i, o );
  input clk, n_rst, i;
  output o;
  wire   n4, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n38, n39, n40, n41;
  wire   [2:0] state;
  wire   [2:0] next_state;

  DFFSR \state_reg[0]  ( .D(next_state[0]), .CLK(clk), .R(1'b1), .S(n_rst), 
        .Q(state[0]) );
  DFFSR \state_reg[1]  ( .D(n4), .CLK(clk), .R(n_rst), .S(1'b1), .Q(state[1])
         );
  DFFSR \state_reg[2]  ( .D(next_state[2]), .CLK(clk), .R(n_rst), .S(1'b1), 
        .Q(state[2]) );
  INVX1 U28 ( .A(n24), .Y(o) );
  NAND2X1 U29 ( .A(n25), .B(n26), .Y(next_state[2]) );
  MUX2X1 U30 ( .B(n27), .A(n28), .S(i), .Y(n25) );
  INVX1 U31 ( .A(n29), .Y(n28) );
  AND2X1 U32 ( .A(state[0]), .B(n30), .Y(n27) );
  OR2X1 U33 ( .A(n31), .B(n32), .Y(next_state[0]) );
  OAI21X1 U34 ( .A(i), .B(n33), .C(n34), .Y(n32) );
  MUX2X1 U35 ( .B(n30), .A(n35), .S(state[0]), .Y(n34) );
  INVX1 U36 ( .A(n26), .Y(n35) );
  NAND3X1 U37 ( .A(n36), .B(n24), .C(n29), .Y(n31) );
  NAND3X1 U38 ( .A(n37), .B(n38), .C(state[2]), .Y(n29) );
  NAND2X1 U39 ( .A(state[2]), .B(n39), .Y(n24) );
  OAI21X1 U40 ( .A(n33), .B(n40), .C(n41), .Y(n4) );
  AND2X1 U41 ( .A(n26), .B(n36), .Y(n41) );
  NAND2X1 U42 ( .A(n30), .B(i), .Y(n36) );
  NOR2X1 U43 ( .A(n38), .B(state[2]), .Y(n30) );
  INVX1 U44 ( .A(state[1]), .Y(n38) );
  NAND2X1 U45 ( .A(state[1]), .B(state[2]), .Y(n26) );
  INVX1 U46 ( .A(i), .Y(n40) );
  INVX1 U47 ( .A(n39), .Y(n33) );
  NOR2X1 U48 ( .A(n37), .B(state[1]), .Y(n39) );
  INVX1 U49 ( .A(state[0]), .Y(n37) );
endmodule

