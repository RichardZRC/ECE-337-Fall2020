module ahb_lite_slave (
    input wire clk,
    input wire n_rst,
    output reg [15:0] sample_data,
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

    reg [15:0][7:0] data_table, next_data_table;
    // reg [15:0] next_sample_data, next_fir_coefficient;
    reg next_data_ready, temp_hsize, temp_hwrite;
    reg [3:0] temp_haddr;
    reg[1:0] temp_htrans;

    always_ff @(posedge clk, negedge n_rst) begin: Reg
        if (n_rst == 1'b0) begin
            data_table <= '0;
            // sample_data <= '0;
            // fir_coefficient <= '0;
            data_ready <= '0;
            // new_coefficient_set <= '0;
            // hresp <= '0;
            temp_haddr <= '0;
            temp_hsize <= '0;
            temp_htrans <= '0;
            temp_hwrite <= '0;
        end else begin
            data_table <= next_data_table;
            // sample_data <= next_sample_data;
            // fir_coefficient <= next_fir_coefficient;
            data_ready <= next_data_ready;
            // new_coefficient_set <= next_new_coefficient_set;
            // hresp <= next_hresp;
            temp_haddr <= haddr;
            temp_hsize <= hsize;
            temp_htrans <= htrans;
            temp_hwrite <= hwrite;
        end
    end

    always_comb begin
        hrdata = '0;
        // next_new_coefficient_set = new_coefficient_set;
        // next_hresp = '0;
        // next_hrdata = hrdata;
        next_data_table = data_table;
        // next_fir_coefficient = fir_coefficient;
        next_data_ready = data_ready;
        hresp = 0;
        sample_data = {data_table[5], data_table[4]};
        next_data_table[2] = fir_out[7:0];
        next_data_table[3] = fir_out[15:8];
        new_coefficient_set = data_table[14];
        // next_sample_data = sample_data;

        if (new_coefficient_set || modwait) begin
            next_data_table[0] = 1;
            next_data_table[1] = 0;
        end else if (err) begin
            next_data_table[0] = 0;
            next_data_table[1] = 1;
        end else begin
            next_data_table[0] = 0;
            next_data_table[1] = 0;
        end

        if ((hsel && hwrite && (haddr == 0 || haddr == 1 || haddr == 2 || haddr == 3)) || !hsize && (haddr == 15)) begin
            hresp = 1'b1;
        end

        if (hsel && (temp_htrans != 0)) begin
            if (temp_hwrite) begin
                if (temp_hsize && ((temp_haddr != 0) && (temp_haddr != 1) && (temp_haddr != 2) && (temp_haddr != 3))) begin
                    if (temp_haddr % 2 == 0) begin
                        next_data_table[temp_haddr + 1] = hwdata[15:8];
                        next_data_table[temp_haddr] = hwdata[7:0];
                    end else begin
                        next_data_table[temp_haddr] = hwdata[15:8];
                        next_data_table[temp_haddr - 1] = hwdata[7:0];
                    end
                end else if (!temp_hsize && ((temp_haddr != 0) && (temp_haddr != 1) && (temp_haddr != 2) && (temp_haddr != 3))) begin
                    if (temp_haddr % 2 == 0) begin
                        next_data_table[temp_haddr] = hwdata[7:0];
                    end else begin
                        next_data_table[temp_haddr] = hwdata[15:8];
                    end
                end

                if ((temp_haddr == 4 || temp_haddr == 5)) begin
                    next_data_ready = 1'b1;
                end 
            end else begin
                if (temp_hsize) begin
                    if (temp_haddr % 2 == 0) begin
                        hrdata = {data_table[temp_haddr + 1], data_table[temp_haddr]};
                    end else begin
                        hrdata = {data_table[temp_haddr], data_table[temp_haddr - 1]};
                    end
                end else begin
                    if (temp_haddr % 2 == 0) begin
                        hrdata[7:0] = data_table[temp_haddr];
                    end else begin
                        hrdata[15:8] = data_table[temp_haddr];
                    end
                end
            end
        end



        // if (hsel && (temp_htrans != 0)) begin
        //     if (temp_haddr == 4'b0000) begin
        //         if (temp_hwrite) begin
        //             hresp = 1'b1;
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 if (new_coefficient_set || modwait) begin
        //                     // next_hrdata = 1'b1;
        //                     hrdata = 1'b1;
        //                 end else begin
        //                     // next_hrdata = 0;
        //                     hrdata = 0;
        //                 end
        //             end else begin
        //                 if (new_coefficient_set || modwait) begin
        //                     // next_hrdata = 1'b1;
        //                     hrdata = 1'b1;
        //                 end else if (err) begin
        //                     // next_hrdata = {7'b0, 1'b1, 8'b0};
        //                     hrdata = {7'b0, 1'b1, 8'b0};
        //                 end else begin
        //                     // next_hrdata = '0;
        //                     hrdata = '0;
        //                 end
        //             end
        //         end

        //     end else if (temp_haddr == 4'b0001) begin
        //         if (temp_hwrite) begin
        //             next_hresp = 1'b1;
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 if (err) begin
        //                     // next_hrdata = {7'b0, 1'b1, 8'b0};
        //                     hrdata = {7'b0, 1'b1, 8'b0};
        //                 end else begin
        //                     // next_hrdata = '0;
        //                     hrdata = '0;
        //                 end
        //             end else begin
        //                 if (new_coefficient_set || modwait) begin
        //                     // next_hrdata = 1'b1;
        //                     hrdata = 1'b1;
        //                 end else if (err) begin
        //                     // next_hrdata = {7'b0, 1'b1, 8'b0};
        //                     hrdata = {7'b0, 1'b1, 8'b0};
        //                 end else begin
        //                     // next_hrdata = '0;
        //                     hrdata = '0;
        //                 end
        //             end
        //         end

        //     end else if (temp_haddr == 4'b0010) begin
        //         if (temp_hwrite) begin
        //             next_hresp = 1'b1;
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 // next_hrdata = {8'b0, fir_out[7:0]};
        //                 hrdata = {8'b0, fir_out[7:0]};
        //             end else begin
        //                 // next_hrdata = fir_out;
        //                 hrdata = fir_out;
        //             end
        //         end

        //     end else if (temp_haddr == 4'b0011) begin
        //         if (temp_hwrite) begin
        //             next_hresp = 1'b1;
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 // next_hrdata = {fir_out[15:8], 8'b0};
        //                 hrdata = {fir_out[15:8], 8'b0};
        //             end else begin
        //                 // next_hrdata = fir_out;
        //                 hrdata = fir_out;
        //             end
        //         end

        //     end else if (temp_haddr == 4'b0100) begin
        //         if (temp_hwrite) begin
        //             if (temp_hsize == 0) begin
        //                 next_sample_data[7:0] = hwdata[7:0];
        //             end else begin
        //                 next_sample_data = hwdata;
        //                 next_data_ready = 1'b1;
        //             end
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 // next_hrdata[7:0] = sample_data[7:0];
        //                 hrdata[7:0] = sample_data[7:0];
        //             end else begin
        //                 // next_hrdata = sample_data;
        //                 hrdata = sample_data;
        //             end
        //         end
            
        //     end else if (temp_haddr == 4'b0101) begin
        //         if (temp_hwrite) begin
        //             if (temp_hsize == 0) begin
        //                 next_sample_data[15:8] = hwdata[15:8];
        //             end else begin
        //                 next_sample_data = hwdata;
        //                 next_data_ready = 1'b1;
        //             end
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 // next_hrdata[15:8] = sample_data[15:8];
        //                 hrdata[15:8] = sample_data[15:8];
        //             end else begin
        //                 // next_hrdata = sample_data;
        //                 hrdata = sample_data;
        //             end
        //         end 

        //     end else if (temp_haddr == 6 || temp_haddr == 8 || temp_haddr == 10 || temp_haddr == 12) begin
        //         if (temp_hwrite) begin
        //             if (temp_hsize == 0) begin
        //                 next_data_table[temp_haddr / 2'd2 - 2'd3][7:0] = hwdata[7:0];
        //             end else begin
        //                 next_data_table[temp_haddr / 2'd2 - 2'd3] = hwdata[15:0];
        //             end
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 // next_hrdata = {8'b0, next_data_table[temp_haddr / 2'd2 - 2'd3][7:0]};
        //                 hrdata = {8'b0, next_data_table[temp_haddr / 2'd2 - 2'd3][7:0]};
        //             end else begin
        //                 // next_hrdata = next_data_table[temp_haddr / 2'd2 - 2'd3];
        //                 hrdata = next_data_table[temp_haddr / 2'd2 - 2'd3];
        //             end
        //         end

        //     end else if (temp_haddr == 7 || temp_haddr == 9 || temp_haddr == 11 || temp_haddr == 13) begin
        //         if (temp_hwrite) begin
        //             if (temp_hsize == 0) begin
        //                 next_data_table[temp_haddr / 2'd2 - 2'd3][15:8] = hwdata[15:8];
        //             end else begin
        //                 next_data_table[temp_haddr / 2'd2 - 2'd3] = hwdata[15:0];
        //             end
        //         end else begin
        //             if (temp_hsize == 0) begin
        //                 // next_hrdata = {next_data_table[temp_haddr / 2'd2 - 2'd3][15:8], 8'b0};
        //                 hrdata = {next_data_table[temp_haddr / 2'd2 - 2'd3][15:8], 8'b0};
        //             end else begin
        //                 // next_hrdata = next_data_table[temp_haddr / 2'd2 - 2'd3];
        //                 hrdata = next_data_table[temp_haddr / 2'd2 - 2'd3];
        //             end
        //         end
                
        //     end else if (temp_haddr == 14) begin
        //         if (temp_hwrite) begin
        //             next_new_coefficient_set = hwdata[0];
        //         end else begin
        //             // next_hrdata = new_coefficient_set;
        //             hrdata = new_coefficient_set;
        //         end

        //     end else if (temp_haddr == 15) begin
        //         if (temp_hsize == 0) begin
        //             next_hresp = 1'b1;
        //         end else begin
        //             if (temp_hwrite) begin
        //                 next_new_coefficient_set = hwdata[0];
        //             end else begin
        //                 // next_hrdata = new_coefficient_set;
        //                 hrdata = new_coefficient_set;
        //             end
        //         end
        //     end
        // end

        if (coefficient_num == 0) begin
            fir_coefficient = {data_table[7], data_table[6]};
        end else if (coefficient_num == 1) begin
            fir_coefficient = {data_table[9], data_table[8]};
        end else if (coefficient_num == 2) begin
            fir_coefficient = {data_table[11], data_table[10]};
        end else if (coefficient_num == 3) begin
            fir_coefficient = {data_table[13], data_table[12]};
        end

        if (coefficient_num == 3) begin
            next_data_table[14] = 0;
        end

        if (modwait) begin
            next_data_ready = 0;
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



endmodule