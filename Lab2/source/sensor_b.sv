module sensor_b (
    input wire [3:0] sensors,
    output reg error
);

    always_comb begin 
        error = sensors[1] & sensors[2] | sensors[1] & sensors[3] | sensors[0];
    end
    
endmodule