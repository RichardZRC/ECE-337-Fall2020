/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Tue Sep 15 02:22:15 2020
/////////////////////////////////////////////////////////////


module adder_16_DW01_add_1 ( A, B, CI, SUM, CO );
  input [16:0] A;
  input [16:0] B;
  output [16:0] SUM;
  input CI;
  output CO;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n10, n11, n12, n13, n14, n15, n16,
         n17, n19, n21, n22, n23, n24, n25, n27, n29, n30, n31, n32, n33, n35,
         n37, n38, n39, n40, n41, n43, n45, n46, n47, n48, n49, n50, n52, n54,
         n56, n58, n116, n117, n118, n119;

  FAX1 U2 ( .A(B[15]), .B(A[15]), .C(n10), .YC(SUM[16]), .YS(SUM[15]) );
  FAX1 U3 ( .A(B[14]), .B(A[14]), .C(n11), .YC(n10), .YS(SUM[14]) );
  FAX1 U4 ( .A(B[13]), .B(A[13]), .C(n12), .YC(n11), .YS(SUM[13]) );
  FAX1 U5 ( .A(B[12]), .B(A[12]), .C(n13), .YC(n12), .YS(SUM[12]) );
  FAX1 U6 ( .A(B[11]), .B(A[11]), .C(n14), .YC(n13), .YS(SUM[11]) );
  FAX1 U7 ( .A(B[10]), .B(A[10]), .C(n15), .YC(n14), .YS(SUM[10]) );
  FAX1 U8 ( .A(B[9]), .B(A[9]), .C(n16), .YC(n15), .YS(SUM[9]) );
  FAX1 U9 ( .A(B[8]), .B(A[8]), .C(n50), .YC(n16), .YS(SUM[8]) );
  XNOR2X1 U11 ( .A(n22), .B(n1), .Y(SUM[7]) );
  AOI21X1 U12 ( .A(n119), .B(n22), .C(n19), .Y(n17) );
  NAND2X1 U15 ( .A(n21), .B(n119), .Y(n1) );
  NAND2X1 U18 ( .A(B[7]), .B(A[7]), .Y(n21) );
  XOR2X1 U19 ( .A(n25), .B(n2), .Y(SUM[6]) );
  OAI21X1 U20 ( .A(n25), .B(n23), .C(n24), .Y(n22) );
  NAND2X1 U21 ( .A(n24), .B(n52), .Y(n2) );
  NOR2X1 U23 ( .A(B[6]), .B(A[6]), .Y(n23) );
  NAND2X1 U24 ( .A(B[6]), .B(A[6]), .Y(n24) );
  XNOR2X1 U25 ( .A(n30), .B(n3), .Y(SUM[5]) );
  AOI21X1 U26 ( .A(n118), .B(n30), .C(n27), .Y(n25) );
  NAND2X1 U29 ( .A(n29), .B(n118), .Y(n3) );
  NAND2X1 U32 ( .A(B[5]), .B(A[5]), .Y(n29) );
  XOR2X1 U33 ( .A(n33), .B(n4), .Y(SUM[4]) );
  OAI21X1 U34 ( .A(n33), .B(n31), .C(n32), .Y(n30) );
  NAND2X1 U35 ( .A(n32), .B(n54), .Y(n4) );
  NOR2X1 U37 ( .A(B[4]), .B(A[4]), .Y(n31) );
  NAND2X1 U38 ( .A(B[4]), .B(A[4]), .Y(n32) );
  XNOR2X1 U39 ( .A(n38), .B(n5), .Y(SUM[3]) );
  AOI21X1 U40 ( .A(n117), .B(n38), .C(n35), .Y(n33) );
  NAND2X1 U43 ( .A(n37), .B(n117), .Y(n5) );
  NAND2X1 U46 ( .A(B[3]), .B(A[3]), .Y(n37) );
  XOR2X1 U47 ( .A(n41), .B(n6), .Y(SUM[2]) );
  OAI21X1 U48 ( .A(n41), .B(n39), .C(n40), .Y(n38) );
  NAND2X1 U49 ( .A(n40), .B(n56), .Y(n6) );
  NOR2X1 U51 ( .A(B[2]), .B(A[2]), .Y(n39) );
  NAND2X1 U52 ( .A(B[2]), .B(A[2]), .Y(n40) );
  XNOR2X1 U53 ( .A(n46), .B(n7), .Y(SUM[1]) );
  AOI21X1 U54 ( .A(n116), .B(n46), .C(n43), .Y(n41) );
  NAND2X1 U57 ( .A(n45), .B(n116), .Y(n7) );
  NAND2X1 U60 ( .A(B[1]), .B(A[1]), .Y(n45) );
  XNOR2X1 U61 ( .A(n8), .B(CI), .Y(SUM[0]) );
  OAI21X1 U62 ( .A(n47), .B(n49), .C(n48), .Y(n46) );
  NAND2X1 U63 ( .A(n48), .B(n58), .Y(n8) );
  NOR2X1 U65 ( .A(B[0]), .B(A[0]), .Y(n47) );
  NAND2X1 U66 ( .A(B[0]), .B(A[0]), .Y(n48) );
  OR2X2 U71 ( .A(B[1]), .B(A[1]), .Y(n116) );
  OR2X2 U72 ( .A(B[3]), .B(A[3]), .Y(n117) );
  OR2X2 U73 ( .A(B[5]), .B(A[5]), .Y(n118) );
  OR2X2 U74 ( .A(B[7]), .B(A[7]), .Y(n119) );
  INVX2 U75 ( .A(n47), .Y(n58) );
  INVX2 U76 ( .A(n39), .Y(n56) );
  INVX2 U77 ( .A(n31), .Y(n54) );
  INVX2 U78 ( .A(n23), .Y(n52) );
  INVX2 U79 ( .A(n17), .Y(n50) );
  INVX2 U80 ( .A(CI), .Y(n49) );
  INVX2 U81 ( .A(n45), .Y(n43) );
  INVX2 U82 ( .A(n37), .Y(n35) );
  INVX2 U83 ( .A(n29), .Y(n27) );
  INVX2 U84 ( .A(n21), .Y(n19) );
endmodule


module adder_16 ( a, b, carry_in, sum, overflow );
  input [15:0] a;
  input [15:0] b;
  output [15:0] sum;
  input carry_in;
  output overflow;


  adder_16_DW01_add_1 r300 ( .A({1'b0, a}), .B({1'b0, b}), .CI(carry_in), 
        .SUM({overflow, sum}) );
endmodule

