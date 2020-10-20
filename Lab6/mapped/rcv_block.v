/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP1
// Date      : Tue Oct  6 11:15:59 2020
/////////////////////////////////////////////////////////////


module start_bit_det ( clk, n_rst, serial_in, start_bit_detected, 
        new_package_detected );
  input clk, n_rst, serial_in;
  output start_bit_detected, new_package_detected;
  wire   start_bit_detected, old_sample, new_sample, sync_phase, n4;
  assign new_package_detected = start_bit_detected;

  DFFSR sync_phase_reg ( .D(serial_in), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        sync_phase) );
  DFFSR new_sample_reg ( .D(sync_phase), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        new_sample) );
  DFFSR old_sample_reg ( .D(new_sample), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        old_sample) );
  NOR2X1 U7 ( .A(n4), .B(new_sample), .Y(start_bit_detected) );
  INVX2 U6 ( .A(old_sample), .Y(n4) );
endmodule


module flex_stp_sr_NUM_BITS9_SHIFT_MSB0 ( clk, n_rst, serial_in, shift_enable, 
        parallel_out );
  output [8:0] parallel_out;
  input clk, n_rst, serial_in, shift_enable;
  wire   n3, n11, n13, n15, n17, n19, n21, n23, n25, n27, n29, n1, n2, n4, n5,
         n6, n7, n8, n9, n10;

  DFFSR \parallel_out_reg[8]  ( .D(n29), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[8]) );
  DFFSR \parallel_out_reg[7]  ( .D(n27), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[7]) );
  DFFSR \parallel_out_reg[6]  ( .D(n25), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[6]) );
  DFFSR \parallel_out_reg[5]  ( .D(n23), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[5]) );
  DFFSR \parallel_out_reg[4]  ( .D(n21), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[4]) );
  DFFSR \parallel_out_reg[3]  ( .D(n19), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[3]) );
  DFFSR \parallel_out_reg[2]  ( .D(n17), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[2]) );
  DFFSR \parallel_out_reg[1]  ( .D(n15), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[1]) );
  DFFSR \parallel_out_reg[0]  ( .D(n13), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        parallel_out[0]) );
  OAI21X1 U2 ( .A(n10), .B(n1), .C(n3), .Y(n13) );
  NAND2X1 U3 ( .A(parallel_out[0]), .B(n1), .Y(n3) );
  OAI22X1 U4 ( .A(n1), .B(n9), .C(shift_enable), .D(n10), .Y(n15) );
  OAI22X1 U6 ( .A(n1), .B(n8), .C(shift_enable), .D(n9), .Y(n17) );
  OAI22X1 U8 ( .A(n1), .B(n7), .C(shift_enable), .D(n8), .Y(n19) );
  OAI22X1 U10 ( .A(n1), .B(n6), .C(shift_enable), .D(n7), .Y(n21) );
  OAI22X1 U12 ( .A(n1), .B(n5), .C(shift_enable), .D(n6), .Y(n23) );
  OAI22X1 U14 ( .A(n1), .B(n4), .C(shift_enable), .D(n5), .Y(n25) );
  OAI22X1 U16 ( .A(n1), .B(n2), .C(shift_enable), .D(n4), .Y(n27) );
  OAI21X1 U19 ( .A(shift_enable), .B(n2), .C(n11), .Y(n29) );
  NAND2X1 U20 ( .A(serial_in), .B(shift_enable), .Y(n11) );
  INVX2 U5 ( .A(shift_enable), .Y(n1) );
  INVX2 U7 ( .A(parallel_out[8]), .Y(n2) );
  INVX2 U9 ( .A(parallel_out[7]), .Y(n4) );
  INVX2 U11 ( .A(parallel_out[6]), .Y(n5) );
  INVX2 U13 ( .A(parallel_out[5]), .Y(n6) );
  INVX2 U15 ( .A(parallel_out[4]), .Y(n7) );
  INVX2 U17 ( .A(parallel_out[3]), .Y(n8) );
  INVX2 U18 ( .A(parallel_out[2]), .Y(n9) );
  INVX2 U21 ( .A(parallel_out[1]), .Y(n10) );
endmodule


module sr_9bit ( clk, n_rst, shift_strobe, serial_in, packet_data, stop_bit );
  output [7:0] packet_data;
  input clk, n_rst, shift_strobe, serial_in;
  output stop_bit;


  flex_stp_sr_NUM_BITS9_SHIFT_MSB0 SR1 ( .clk(clk), .n_rst(n_rst), .serial_in(
        serial_in), .shift_enable(shift_strobe), .parallel_out({stop_bit, 
        packet_data}) );
endmodule


module stop_bit_chk ( clk, n_rst, sbc_clear, sbc_enable, stop_bit, 
        framing_error );
  input clk, n_rst, sbc_clear, sbc_enable, stop_bit;
  output framing_error;
  wire   n4, n5, n2, n3;

  DFFSR framing_error_reg ( .D(n5), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        framing_error) );
  NOR2X1 U5 ( .A(sbc_clear), .B(n4), .Y(n5) );
  AOI22X1 U6 ( .A(framing_error), .B(n3), .C(sbc_enable), .D(n2), .Y(n4) );
  INVX2 U3 ( .A(stop_bit), .Y(n2) );
  INVX2 U4 ( .A(sbc_enable), .Y(n3) );
endmodule


module flex_counter_NUM_CNT_BITS4_1 ( clear, n_rst, clk, count_enable, 
        rollover_val, count_out, rollover_flag );
  input [3:0] rollover_val;
  output [3:0] count_out;
  input clear, n_rst, clk, count_enable;
  output rollover_flag;
  wire   N2, N3, N4, N6, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35,
         n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49,
         n50, n51, n52, n53, n54, n55, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
         n16, n17, n18, n19, n20, n21, n22, n23, n24;

  DFFSR \count_out_reg[0]  ( .D(n55), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[0]) );
  DFFSR \count_out_reg[3]  ( .D(n52), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[3]) );
  DFFSR \count_out_reg[1]  ( .D(n54), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[1]) );
  DFFSR \count_out_reg[2]  ( .D(n53), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[2]) );
  DFFSR rollover_flag_reg ( .D(n51), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        rollover_flag) );
  OAI21X1 U18 ( .A(n25), .B(n26), .C(n27), .Y(n51) );
  NAND2X1 U19 ( .A(rollover_flag), .B(n28), .Y(n27) );
  NAND3X1 U20 ( .A(n29), .B(n30), .C(n31), .Y(n26) );
  NOR2X1 U21 ( .A(n32), .B(n33), .Y(n31) );
  XNOR2X1 U23 ( .A(n20), .B(N2), .Y(n32) );
  XNOR2X1 U24 ( .A(n6), .B(N3), .Y(n30) );
  XNOR2X1 U25 ( .A(n4), .B(N4), .Y(n29) );
  NAND3X1 U26 ( .A(n24), .B(n34), .C(n35), .Y(n25) );
  NOR2X1 U27 ( .A(n2), .B(N6), .Y(n35) );
  OAI22X1 U28 ( .A(n24), .B(n21), .C(n36), .D(n37), .Y(n52) );
  XNOR2X1 U29 ( .A(count_out[3]), .B(n38), .Y(n36) );
  NOR2X1 U30 ( .A(n23), .B(n19), .Y(n38) );
  OAI21X1 U31 ( .A(n39), .B(n23), .C(n40), .Y(n53) );
  NAND3X1 U32 ( .A(n41), .B(n23), .C(n5), .Y(n40) );
  AOI21X1 U33 ( .A(n18), .B(n19), .C(n28), .Y(n39) );
  NOR2X1 U34 ( .A(n22), .B(n20), .Y(n41) );
  OAI21X1 U35 ( .A(n42), .B(n22), .C(n43), .Y(n54) );
  NAND3X1 U36 ( .A(count_out[0]), .B(n22), .C(n5), .Y(n43) );
  AOI21X1 U37 ( .A(n3), .B(n20), .C(n28), .Y(n42) );
  OAI21X1 U38 ( .A(n24), .B(n20), .C(n44), .Y(n55) );
  AOI22X1 U39 ( .A(n45), .B(n17), .C(n5), .D(n20), .Y(n44) );
  NAND3X1 U40 ( .A(n34), .B(n1), .C(n24), .Y(n37) );
  NAND3X1 U41 ( .A(n46), .B(n47), .C(n48), .Y(n34) );
  NOR2X1 U42 ( .A(n49), .B(n50), .Y(n48) );
  XNOR2X1 U43 ( .A(rollover_val[0]), .B(n20), .Y(n50) );
  XNOR2X1 U44 ( .A(rollover_val[3]), .B(n21), .Y(n49) );
  XNOR2X1 U45 ( .A(count_out[2]), .B(rollover_val[2]), .Y(n47) );
  XNOR2X1 U46 ( .A(n6), .B(rollover_val[1]), .Y(n46) );
  NOR2X1 U47 ( .A(n2), .B(n28), .Y(n45) );
  NOR2X1 U48 ( .A(clear), .B(count_enable), .Y(n28) );
  XOR2X1 U8 ( .A(n21), .B(n10), .Y(n33) );
  INVX1 U9 ( .A(clear), .Y(n1) );
  INVX2 U10 ( .A(n1), .Y(n2) );
  INVX1 U11 ( .A(n37), .Y(n3) );
  INVX1 U12 ( .A(n37), .Y(n18) );
  BUFX2 U13 ( .A(count_out[2]), .Y(n4) );
  INVX2 U14 ( .A(n37), .Y(n5) );
  BUFX2 U15 ( .A(count_out[1]), .Y(n6) );
  NOR2X1 U16 ( .A(rollover_val[1]), .B(rollover_val[0]), .Y(n8) );
  AOI21X1 U17 ( .A(rollover_val[0]), .B(rollover_val[1]), .C(n8), .Y(n7) );
  NAND2X1 U22 ( .A(n8), .B(n16), .Y(n9) );
  OAI21X1 U49 ( .A(n8), .B(n16), .C(n9), .Y(N4) );
  NOR2X1 U50 ( .A(n9), .B(rollover_val[3]), .Y(N6) );
  AOI21X1 U51 ( .A(n9), .B(rollover_val[3]), .C(N6), .Y(n10) );
  INVX2 U52 ( .A(rollover_val[2]), .Y(n16) );
  INVX2 U53 ( .A(rollover_val[0]), .Y(N2) );
  INVX2 U54 ( .A(n7), .Y(N3) );
  INVX2 U55 ( .A(n34), .Y(n17) );
  INVX2 U56 ( .A(n41), .Y(n19) );
  INVX2 U57 ( .A(count_out[0]), .Y(n20) );
  INVX2 U58 ( .A(count_out[3]), .Y(n21) );
  INVX2 U59 ( .A(count_out[1]), .Y(n22) );
  INVX2 U60 ( .A(n4), .Y(n23) );
  INVX2 U61 ( .A(n28), .Y(n24) );
endmodule


module flex_counter_NUM_CNT_BITS4_0 ( clear, n_rst, clk, count_enable, 
        rollover_val, count_out, rollover_flag );
  input [3:0] rollover_val;
  output [3:0] count_out;
  input clear, n_rst, clk, count_enable;
  output rollover_flag;
  wire   N2, N3, N4, N5, N6, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n16, n17,
         n18, n19, n20, n21, n22, n23, n24, n51, n52, n53, n54, n55, n56, n57,
         n58, n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71,
         n72, n73, n74, n75, n76;

  DFFSR \count_out_reg[0]  ( .D(n20), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[0]) );
  DFFSR \count_out_reg[3]  ( .D(n23), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[3]) );
  DFFSR \count_out_reg[1]  ( .D(n21), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[1]) );
  DFFSR \count_out_reg[2]  ( .D(n22), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        count_out[2]) );
  DFFSR rollover_flag_reg ( .D(n24), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        rollover_flag) );
  OAI21X1 U18 ( .A(n76), .B(n75), .C(n74), .Y(n24) );
  NAND2X1 U19 ( .A(rollover_flag), .B(n73), .Y(n74) );
  NAND3X1 U20 ( .A(n72), .B(n71), .C(n70), .Y(n75) );
  NOR2X1 U21 ( .A(n69), .B(n68), .Y(n70) );
  XNOR2X1 U22 ( .A(n16), .B(N5), .Y(n68) );
  XNOR2X1 U23 ( .A(n10), .B(N2), .Y(n69) );
  XNOR2X1 U24 ( .A(count_out[1]), .B(N3), .Y(n71) );
  XNOR2X1 U25 ( .A(count_out[2]), .B(N4), .Y(n72) );
  NAND3X1 U26 ( .A(n1), .B(n67), .C(n66), .Y(n76) );
  NOR2X1 U27 ( .A(clear), .B(N6), .Y(n66) );
  OAI22X1 U28 ( .A(n1), .B(n16), .C(n65), .D(n64), .Y(n23) );
  XNOR2X1 U29 ( .A(count_out[3]), .B(n63), .Y(n65) );
  NOR2X1 U30 ( .A(n18), .B(n9), .Y(n63) );
  OAI21X1 U31 ( .A(n62), .B(n18), .C(n61), .Y(n22) );
  NAND3X1 U32 ( .A(n60), .B(n18), .C(n8), .Y(n61) );
  AOI21X1 U33 ( .A(n8), .B(n9), .C(n73), .Y(n62) );
  NOR2X1 U34 ( .A(n17), .B(n10), .Y(n60) );
  OAI21X1 U35 ( .A(n59), .B(n17), .C(n58), .Y(n21) );
  NAND3X1 U36 ( .A(count_out[0]), .B(n17), .C(n8), .Y(n58) );
  AOI21X1 U37 ( .A(n8), .B(n10), .C(n73), .Y(n59) );
  OAI21X1 U38 ( .A(n1), .B(n10), .C(n57), .Y(n20) );
  AOI22X1 U39 ( .A(n56), .B(n7), .C(n8), .D(n10), .Y(n57) );
  NAND3X1 U40 ( .A(n67), .B(n19), .C(n1), .Y(n64) );
  NAND3X1 U41 ( .A(n55), .B(n54), .C(n53), .Y(n67) );
  NOR2X1 U42 ( .A(n52), .B(n51), .Y(n53) );
  XNOR2X1 U43 ( .A(rollover_val[0]), .B(n10), .Y(n51) );
  XNOR2X1 U44 ( .A(rollover_val[3]), .B(n16), .Y(n52) );
  XNOR2X1 U45 ( .A(count_out[2]), .B(rollover_val[2]), .Y(n54) );
  XNOR2X1 U46 ( .A(count_out[1]), .B(rollover_val[1]), .Y(n55) );
  NOR2X1 U47 ( .A(clear), .B(n73), .Y(n56) );
  INVX4 U8 ( .A(n64), .Y(n8) );
  OR2X2 U9 ( .A(clear), .B(count_enable), .Y(n1) );
  INVX2 U10 ( .A(n1), .Y(n73) );
  INVX1 U11 ( .A(clear), .Y(n19) );
  NOR2X1 U12 ( .A(rollover_val[1]), .B(rollover_val[0]), .Y(n3) );
  AOI21X1 U13 ( .A(rollover_val[0]), .B(rollover_val[1]), .C(n3), .Y(n2) );
  NAND2X1 U14 ( .A(n3), .B(n6), .Y(n4) );
  OAI21X1 U15 ( .A(n3), .B(n6), .C(n4), .Y(N4) );
  NOR2X1 U16 ( .A(n4), .B(rollover_val[3]), .Y(N6) );
  AOI21X1 U17 ( .A(n4), .B(rollover_val[3]), .C(N6), .Y(n5) );
  INVX2 U48 ( .A(rollover_val[2]), .Y(n6) );
  INVX2 U49 ( .A(rollover_val[0]), .Y(N2) );
  INVX2 U50 ( .A(n5), .Y(N5) );
  INVX2 U51 ( .A(n2), .Y(N3) );
  INVX2 U52 ( .A(n67), .Y(n7) );
  INVX2 U53 ( .A(n60), .Y(n9) );
  INVX2 U54 ( .A(count_out[0]), .Y(n10) );
  INVX2 U55 ( .A(count_out[3]), .Y(n16) );
  INVX2 U56 ( .A(count_out[1]), .Y(n17) );
  INVX2 U57 ( .A(count_out[2]), .Y(n18) );
endmodule


module timer ( clk, n_rst, enable_timer, shift_enable, packet_done );
  input clk, n_rst, enable_timer;
  output shift_enable, packet_done;
  wire   n3, n4, n1, n5;
  wire   [3:0] clk_count;

  NAND3X1 U5 ( .A(clk_count[1]), .B(clk_count[0]), .C(n4), .Y(n3) );
  NOR2X1 U6 ( .A(clk_count[3]), .B(clk_count[2]), .Y(n4) );
  flex_counter_NUM_CNT_BITS4_1 CLK_COUNTER ( .clear(n5), .n_rst(n_rst), .clk(
        clk), .count_enable(enable_timer), .rollover_val({1'b1, 1'b0, 1'b1, 
        1'b0}), .count_out(clk_count) );
  flex_counter_NUM_CNT_BITS4_0 BIT_COUNTER ( .clear(n1), .n_rst(n_rst), .clk(
        clk), .count_enable(shift_enable), .rollover_val({1'b1, 1'b0, 1'b1, 
        1'b0}), .rollover_flag(packet_done) );
  INVX2 U3 ( .A(n3), .Y(shift_enable) );
  INVX2 U4 ( .A(enable_timer), .Y(n5) );
  INVX2 U7 ( .A(enable_timer), .Y(n1) );
endmodule


module rcu ( clk, n_rst, start_bit_detected, packet_done, framing_error, 
        sbc_clear, sbc_enable, load_buffer, enable_timer );
  input clk, n_rst, start_bit_detected, packet_done, framing_error;
  output sbc_clear, sbc_enable, load_buffer, enable_timer;
  wire   n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n4,
         n5, n6, n7, n8, n9, n10, n24, n26, enable_timer, n28, n29;
  wire   [2:0] state;
  assign sbc_clear = enable_timer;

  DFFSR \state_reg[0]  ( .D(n23), .CLK(clk), .R(n_rst), .S(1'b1), .Q(state[0])
         );
  DFFSR \state_reg[2]  ( .D(n21), .CLK(clk), .R(n_rst), .S(1'b1), .Q(state[2])
         );
  DFFSR \state_reg[1]  ( .D(n22), .CLK(clk), .R(n_rst), .S(1'b1), .Q(state[1])
         );
  NOR2X1 U13 ( .A(n29), .B(n11), .Y(sbc_enable) );
  NAND2X1 U14 ( .A(n26), .B(n28), .Y(n11) );
  OAI22X1 U15 ( .A(n10), .B(n28), .C(framing_error), .D(n12), .Y(n21) );
  OAI22X1 U16 ( .A(n10), .B(n29), .C(n4), .D(n14), .Y(n22) );
  OAI21X1 U17 ( .A(n10), .B(n26), .C(n15), .Y(n23) );
  NAND3X1 U18 ( .A(n26), .B(n28), .C(n24), .Y(n15) );
  OAI21X1 U19 ( .A(load_buffer), .B(n17), .C(n24), .Y(n16) );
  OAI21X1 U20 ( .A(packet_done), .B(n4), .C(n18), .Y(n14) );
  NAND3X1 U21 ( .A(n29), .B(n28), .C(n19), .Y(n18) );
  NOR2X1 U22 ( .A(n7), .B(start_bit_detected), .Y(n19) );
  NAND2X1 U23 ( .A(n12), .B(n4), .Y(n17) );
  NAND3X1 U24 ( .A(n9), .B(n28), .C(n7), .Y(n12) );
  NAND3X1 U25 ( .A(n26), .B(n29), .C(n8), .Y(n20) );
  NAND3X1 U26 ( .A(state[0]), .B(n6), .C(n5), .Y(n13) );
  INVX2 U6 ( .A(n20), .Y(load_buffer) );
  INVX2 U7 ( .A(n28), .Y(n8) );
  INVX2 U8 ( .A(n13), .Y(enable_timer) );
  BUFX2 U9 ( .A(n13), .Y(n4) );
  INVX1 U10 ( .A(state[1]), .Y(n5) );
  INVX1 U11 ( .A(state[1]), .Y(n29) );
  INVX2 U12 ( .A(state[2]), .Y(n6) );
  INVX1 U27 ( .A(state[2]), .Y(n28) );
  INVX2 U28 ( .A(n26), .Y(n7) );
  INVX1 U29 ( .A(n29), .Y(n9) );
  INVX1 U30 ( .A(state[0]), .Y(n26) );
  INVX2 U31 ( .A(n16), .Y(n10) );
  INVX2 U32 ( .A(n14), .Y(n24) );
endmodule


module rx_data_buff ( clk, n_rst, load_buffer, packet_data, data_read, rx_data, 
        data_ready, overrun_error );
  input [7:0] packet_data;
  output [7:0] rx_data;
  input clk, n_rst, load_buffer, data_read;
  output data_ready, overrun_error;
  wire   n1, n3, n4, n5, n6, n7, n8, n9, n10, n30, n31, n2, n11, n15, n17, n19,
         n21, n23, n25, n27, n29;

  DFFSR \rx_data_reg[7]  ( .D(n2), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[7]) );
  DFFSR \rx_data_reg[6]  ( .D(n11), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[6]) );
  DFFSR \rx_data_reg[5]  ( .D(n15), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[5]) );
  DFFSR \rx_data_reg[4]  ( .D(n17), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[4]) );
  DFFSR \rx_data_reg[3]  ( .D(n19), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[3]) );
  DFFSR \rx_data_reg[2]  ( .D(n21), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[2]) );
  DFFSR \rx_data_reg[1]  ( .D(n23), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[1]) );
  DFFSR \rx_data_reg[0]  ( .D(n25), .CLK(clk), .R(1'b1), .S(n_rst), .Q(
        rx_data[0]) );
  DFFSR data_ready_reg ( .D(n31), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        data_ready) );
  DFFSR overrun_error_reg ( .D(n30), .CLK(clk), .R(n_rst), .S(1'b1), .Q(
        overrun_error) );
  AOI22X1 U4 ( .A(rx_data[0]), .B(n29), .C(packet_data[0]), .D(load_buffer), 
        .Y(n1) );
  AOI22X1 U6 ( .A(rx_data[1]), .B(n29), .C(packet_data[1]), .D(load_buffer), 
        .Y(n3) );
  AOI22X1 U8 ( .A(rx_data[2]), .B(n29), .C(packet_data[2]), .D(load_buffer), 
        .Y(n4) );
  AOI22X1 U10 ( .A(rx_data[3]), .B(n29), .C(packet_data[3]), .D(load_buffer), 
        .Y(n5) );
  AOI22X1 U12 ( .A(rx_data[4]), .B(n29), .C(packet_data[4]), .D(load_buffer), 
        .Y(n6) );
  AOI22X1 U14 ( .A(rx_data[5]), .B(n29), .C(packet_data[5]), .D(load_buffer), 
        .Y(n7) );
  AOI22X1 U16 ( .A(rx_data[6]), .B(n29), .C(packet_data[6]), .D(load_buffer), 
        .Y(n8) );
  AOI22X1 U18 ( .A(rx_data[7]), .B(n29), .C(packet_data[7]), .D(load_buffer), 
        .Y(n9) );
  NOR2X1 U19 ( .A(data_read), .B(n10), .Y(n30) );
  AOI21X1 U20 ( .A(data_ready), .B(load_buffer), .C(overrun_error), .Y(n10) );
  OAI21X1 U21 ( .A(data_read), .B(n27), .C(n29), .Y(n31) );
  INVX2 U3 ( .A(load_buffer), .Y(n29) );
  INVX2 U5 ( .A(n9), .Y(n2) );
  INVX2 U7 ( .A(n8), .Y(n11) );
  INVX2 U9 ( .A(n7), .Y(n15) );
  INVX2 U11 ( .A(n6), .Y(n17) );
  INVX2 U13 ( .A(n5), .Y(n19) );
  INVX2 U15 ( .A(n4), .Y(n21) );
  INVX2 U17 ( .A(n3), .Y(n23) );
  INVX2 U22 ( .A(n1), .Y(n25) );
  INVX2 U23 ( .A(data_ready), .Y(n27) );
endmodule


module rcv_block ( clk, n_rst, serial_in, data_read, rx_data, data_ready, 
        overrun_error, framing_error );
  output [7:0] rx_data;
  input clk, n_rst, serial_in, data_read;
  output data_ready, overrun_error, framing_error;
  wire   start_bit_detected, shift_strobe, stop_bit, sbc_enable, sbc_clear,
         enable_timer, packet_done, load_buffer;
  wire   [7:0] packet_data;

  start_bit_det A1 ( .clk(clk), .n_rst(n_rst), .serial_in(serial_in), 
        .start_bit_detected(start_bit_detected) );
  sr_9bit A2 ( .clk(clk), .n_rst(n_rst), .shift_strobe(shift_strobe), 
        .serial_in(serial_in), .packet_data(packet_data), .stop_bit(stop_bit)
         );
  stop_bit_chk A3 ( .clk(clk), .n_rst(n_rst), .sbc_clear(sbc_clear), 
        .sbc_enable(sbc_enable), .stop_bit(stop_bit), .framing_error(
        framing_error) );
  timer A4 ( .clk(clk), .n_rst(n_rst), .enable_timer(enable_timer), 
        .shift_enable(shift_strobe), .packet_done(packet_done) );
  rcu A5 ( .clk(clk), .n_rst(n_rst), .start_bit_detected(start_bit_detected), 
        .packet_done(packet_done), .framing_error(framing_error), .sbc_clear(
        sbc_clear), .sbc_enable(sbc_enable), .load_buffer(load_buffer), 
        .enable_timer(enable_timer) );
  rx_data_buff A6 ( .clk(clk), .n_rst(n_rst), .load_buffer(load_buffer), 
        .packet_data(packet_data), .data_read(data_read), .rx_data(rx_data), 
        .data_ready(data_ready), .overrun_error(overrun_error) );
endmodule

