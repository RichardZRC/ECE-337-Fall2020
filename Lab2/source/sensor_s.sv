module sensor_s (
    input wire [3:0] sensors;
    output wire error;
);
    wire [3:0] temp;

    AND2X1 A1 (.Y(temp[0]), .A(sensors[1]), sensors[2]);
    AND2X1 A2 (.Y(temp[1]), .A(sensors[1]), sensors[3]);
    OR2X1 O1 (.Y(temp[2]), .A(temp[1]), .B(temp[0]));
    OR2X1 O2 (.Y(temp[3]), .A(temp[2]), .B(sensors[0]));

    assign error = temp[3];

endmodule