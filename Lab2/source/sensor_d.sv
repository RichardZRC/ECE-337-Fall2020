module sensor_d (
    input wire [3:0] sensors,
    output wire error
);

    assign error = sensors[1] & sensors[2] | sensors[1] & sensors[3] | sensors[0];

endmodule