module ahb_lite_slave (
    input wire clk,
    input wire n_rst,
    output reg sample_data[15:0],
    output reg data_ready,
    output reg new_coefficient_set,
    input wire [1:0] coefficient_num,
    output reg [15:0] fir_coefficient,
    input wire modwait,
    input wire [15:0] fir_out,
    input wire err,
    input wire hsel,
    input wire [3:0] haddr,
    input wire hsize,
    input wire [1:0] htrans,
    input wire hwrite,
    input wire [15:0] hwdata,
    output reg  [15:0] hrdata,
    output reg hresp 
);

    reg [4:0][15:0] data_table, next_data_table;
    reg [15:0] next_hrdata, next_sample_data, next_fir_coefficient;
    reg next_data_ready, next_new_coefficient_set, next_hresp;

    always_ff @(posedge clk, negedge n_rst) begin: Reg
        if (n_rst == 1'b0) begin
            data_table <= '0;
            hrdata <= '0;
            sample_data <= '0;
            fir_coefficient <= '0;
            data_ready <= '0;
            new_coefficient_set <= '0;
            hresp <= '0;
        end else begin
            data_table <= next_data_table;
            hrdata <= next_hrdata;
            sample_data <= next_sample_data;
            fir_coefficient <= next_fir_coefficient;
            data_ready <= next_data_ready;
            new_coefficient_set <= next_new_coefficient_set;
            hresp <= next_hresp;
        end
    end

    always_comb begin
        next_new_coefficient_set = new_coefficient_set;
        next_hresp = '0;
        next_hrdata = hrdata;
        next_sample_data = data_table[0];
        next_data_table = data_table;
        next_fir_coefficient = fir_coefficient;

        if (hsel && (htrans != 0)) begin
            if (haddr == 4'b0000) begin
                if (hwrite) begin
                    next_hresp = 1'b1;
                end else begin
                    if (hsize == 0) begin
                        if (new_coefficient_set || modwait) begin
                            next_hrdata = 1'b1;
                        end else begin
                            next_hrdata = 0;
                        end
                    end else begin
                        if (new_coefficient_set || modwait) begin
                            next_hrdata = 1'b1;
                        end else if (err) begin
                            next_hrdata = {7'b0, 1'b1, 8'b0};
                        end else begin
                            next_hrdata = '0;
                        end
                    end
                end

            end else if (haddr == 4'b0001) begin
                if (hwrite) begin
                    next_hresp = 1'b1;
                end else begin
                    if (hsize == 0) begin
                        if (err) begin
                            next_hrdata = {7'b0, 1'b1, 8'b0};
                        end else begin
                            next_hrdata = '0;
                        end
                    end else begin
                        if (new_coefficient_set || modwait) begin
                            next_hrdata = 1'b1;
                        end else if (err) begin
                            next_hrdata = {7'b0, 1'b1, 8'b0};
                        end else begin
                            next_hrdata = '0;
                        end
                    end
                end

            end else if (haddr == 4'b0010) begin
                if (hwrite) begin
                    next_hresp = 1'b1;
                end else begin
                    if (hsize == 0) begin
                        next_hrdata = {8'b0, fir_out[7:0]};
                    end else begin
                        next_hrdata = fir_out;
                    end
                end

            end else if (haddr == 4'b0011) begin
                if (hwrite) begin
                    next_hresp = 1'b1;
                end else begin
                    if (hsize == 0) begin
                        next_hrdata = {fir_out[15:8], 8'b0};
                    end else begin
                        next_hrdata = fir_out;
                    end
                end

            end else if (haddr == 4 || haddr == 6 || haddr == 8 || haddr == 10 || haddr == 12) begin
                if (hwrite) begin
                    if (hsize == 0) begin
                        next_data_table[haddr / 2'd2 - 2'd2][7:0] = hwdata[7:0];
                    end else begin
                        next_data_table[haddr / 2'd2 - 2'd2] = hwdata[15:0];
                    end
                end else begin
                    if (hsize == 0) begin
                        next_hrdata = {8'b0, next_data_table[haddr / 2'd2 - 2'd2][7:0]};
                    end else begin
                        next_hrdata = next_data_table[haddr / 2'd2 - 2'd2];
                    end
                end

            end else if (haddr == 5 || haddr == 7 || haddr == 9 || haddr == 11 || haddr == 13) begin
                if (hwrite) begin
                    if (hsize == 0) begin
                        next_data_table[haddr / 2'd2 - 2'd2][15:8] = hwdata[15:8];
                    end else begin
                        next_data_table[haddr / 2'd2 - 2'd2] = hwdata[15:0];
                    end
                end else begin
                    if (hsize == 0) begin
                        next_hrdata = {next_data_table[haddr / 2'd2 - 2'd2][15:8], 8'b0};
                    end else begin
                        next_hrdata = next_data_table[haddr / 2'd2 - 2'd2];
                    end
                end
                
            end else if (haddr == 14) begin
                if (hwrite) begin
                    next_new_coefficient_set = hwdata[0];
                end else begin
                    next_hrdata = new_coefficient_set;
                end

            end else if (haddr == 15) begin
                if (hsize == 0) begin
                    next_hresp = 1'b1;
                end else begin
                    if (hwrite) begin
                        next_new_coefficient_set = hwdata[0];
                    end else begin
                        next_hrdata = new_coefficient_set;
                    end
                end
            end
        end

        if (coefficient_num == 0) begin
            next_fir_coefficient = data_table[1];
        end else if (coefficient_num == 1) begin
            next_fir_coefficient = data_table[2];
        end else if (coefficient_num == 2) begin
            next_fir_coefficient = data_table[3];
        end else if (coefficient_num == 3) begin
            next_fir_coefficient = data_table[4];
            next_new_coefficient_set = 0;
        end
        
    end

    // always_comb begin: Set_Coeff
    //     next_new_coefficient_set = new_coefficient_set;
    //     next_fir_coefficient = fir_coefficient;
    //     if (coefficient_num == 0) begin
    //         next_fir_coefficient = data_table[1];
    //     end else if (coefficient_num == 1) begin
    //         next_fir_coefficient = data_table[2];
    //     end else if (coefficient_num == 2) begin
    //         next_fir_coefficient = data_table[3];
    //     end else if (coefficient_num == 3) begin
    //         next_fir_coefficient = data_table[4];
    //         next_new_coefficient_set = 0;
    //     end
        
    // end

    always_comb begin: Data_ready
        next_data_ready = 1'b0;
        if (hsel && (htrans != 0) && ((haddr == 4) || (haddr == 5)) && (hsize == 1)) begin
            next_data_ready = 1'b1;
        end
    end


endmodule