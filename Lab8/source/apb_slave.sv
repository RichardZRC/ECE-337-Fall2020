module apb_slave (
    input wire clk,
    input wire n_rst,
    input wire [7:0] rx_data,
    input wire data_ready,
    input wire overrun_error,
    input wire framing_error,
    output reg data_read,
    input wire psel,
    input wire [2:0] paddr,
    input wire penable,
    input wire pwrite,
    input wire [7:0] pwdata,
    output reg [7:0] prdata,
    output reg pslverr,
    output reg [3:0] data_size,
    output reg [13:0] bit_period
);

    // typedef enum logic [1:0] { 
    //     idle,
    //     eidle,
    //     configure,
    //     read
    // } state_type;

    // state_type state, next_state;
    reg next_pslverr, next_data_read;
    reg [3:0] next_data_size;
    reg [7:0] next_prdata;
    reg [13:0] next_bit_period;

    // always_ff @(posedge clk, negedge n_rst) begin
    //     if (n_rst == 1'b0) begin
    //         state <= idle;
    //     end else begin
    //         state <= next_state;
    //     end
    // end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            data_size <= 4'b1010;
        end else begin
            data_size <= next_data_size;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            bit_period <= 4'b1010;
        end else begin
            bit_period <= next_bit_period;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            prdata <= '0;
        end else begin
            prdata <= next_prdata;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            data_read <= '0;
        end else begin
            data_read <= next_data_read;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            pslverr <= '0;
        end else begin
            pslverr <= next_pslverr;
        end
    end

    always_comb begin
        next_bit_period = bit_period;
        next_data_size = data_size;
        next_prdata = prdata;
        // prdata = 0;
        next_pslverr = 0;
        next_data_read = 0;
        if (psel) begin
            case (paddr)
                3'b000: begin
                    // if (penable) begin
                        if (pwrite) begin
                            next_pslverr = 1;
                        end else begin
                            next_prdata = data_ready;
                            // prdata = data_ready;
                        end
                    // end
                end

                3'b001: begin
                    // if (penable) begin
                        if (pwrite) begin
                            next_pslverr = 1;
                        end else begin
                            if (framing_error) begin
                                next_prdata = 8'd1;
                                // prdata = 8'd1;
                            end else if (overrun_error) begin
                                next_prdata = 8'd2;
                                // prdata = 8'd2;
                            end else begin
                                next_prdata = '0;
                                // prdata = '0;
                            end
                        end
                    // end
                end

                3'b010: begin
                    // if (penable) begin
                        if (pwrite) begin
                            next_bit_period[7:0] = pwdata;
                        end else begin
                            next_prdata = bit_period[7:0];
                            // prdata = bit_period[7:0];
                        end
                    // end
                end

                3'b011: begin
                    // if (penable) begin
                        if (pwrite) begin
                            next_bit_period[13:8] = pwdata[5:0];
                        end else begin
                            next_prdata = {2'b0, next_bit_period[13:8]};
                            // prdata = {2'b0, next_bit_period[13:8]};
                        end
                    // end
                end

                3'b100: begin
                    // if (penable) begin
                        if (pwrite) begin
                            next_data_size = pwdata;
                        end else begin
                            next_prdata = data_size;
                            // prdata = data_size;
                        end
                    // end
                end

                3'b110: begin
                    // if (penable) begin
                        if (pwrite) begin
                            next_pslverr = 1;
                        end else begin
                            next_data_read = 1;
                            next_prdata = rx_data;
                            // prdata = rx_data;
                        end
                    // end
                end

                3'b101: begin
                    next_pslverr = 1'b1;
                end
                
                default: begin
                    next_pslverr = 1'b1;
                end
            endcase
        end
    end


    // always_comb begin
    //     next_prdata = prdata;
    //     next_state = state;
    //     case (state)
    //         idle: begin
    //             if (psel && pwrite) begin
    //                 next_state = configure;
    //             end else if (psel && !pwrite) begin
    //                 next_state = read;
    //             end
    //         end

    //         configure: begin
    //             if (paddr == 0 || paddr == 1 || paddr == 6) begin
    //                 next_state = eidle;
    //             end else if (psel && pwrite) begin
    //                 next_state = configure;
    //             end else begin
    //                 next_state = idle;
    //             end
    //         end

    //         read: begin
    //             if (psel && !pwrite) begin
    //                 next_state = read;
    //                 if (penable) begin
    //                     if (paddr == 0) begin
    //                         next_prdata = data_ready;
    //                     end else if (paddr == 1) begin
    //                         if (framing_error) begin
    //                             next_prdata = 8'd1;
    //                         end else if (overrun_error) begin
    //                             next_prdata = 8'd2;
    //                         end else begin
    //                             next_prdata = '0;
    //                         end
    //                     end else if (paddr == 6) begin
    //                         next_prdata = rx_data;
    //                     end else if (paddr == 2) begin
    //                         next_prdata = bit_period[7:0];
    //                     end else if (paddr == 3) begin
    //                         next_prdata = {2'b0, bit_period[13:8]};
    //                     end else if (paddr == 4) begin
    //                         next_prdata = data_size;
    //                     end
    //                 end
    //             end else begin
    //                 next_state = idle;
    //             end
    //         end

    //         eidle: begin
    //             if (psel && pwrite) begin
    //                 next_state = configure;
    //             end else if (psel && !pwrite) begin
    //                 next_state = read;
    //             end
    //         end
    //     endcase
    // end

    // always_comb begin
    //     next_bit_period = bit_period;
    //     next_data_size = data_size;
    //     pslverr = 0;
    //     data_read = 0;

    //     case (state)
    //         configure: begin
    //             if (penable) begin
    //                 if (paddr == 2) begin
    //                     next_bit_period[7:0] = pwdata;
    //                 end else if (paddr == 3) begin
    //                     next_bit_period[13:8] = pwdata[5:0];
    //                 end else if (paddr == 4) begin
    //                     next_data_size = pwdata[3:0];
    //                 end
    //             end
    //         end

    //         read: begin
    //             if (paddr == 6) begin
    //                 data_read = 1;
    //             end
    //             // if (penable) begin
    //             //     if (paddr == 0) begin
    //             //         next_prdata = data_ready;
    //             //     end else if (paddr == 1) begin
    //             //         if (framing_error) begin
    //             //             next_prdata = 8'd1;
    //             //         end else if (overrun_error) begin
    //             //             next_prdata = 8'd2;
    //             //         end else begin
    //             //             next_prdata = '0;
    //             //         end
    //             //     end else if (paddr == 6) begin
    //             //         data_read = 1;
    //             //         next_prdata = rx_data;
    //             //     end else if (paddr == 2) begin
    //             //         next_prdata = bit_period[7:0];
    //             //     end else if (paddr == 3) begin
    //             //         next_prdata = {2'b0, bit_period[13:8]};
    //             //     end else if (paddr == 4) begin
    //             //         next_prdata = data_size;
    //             //     end
    //             // end
    //         end

    //         eidle: begin
    //             pslverr = 1;
    //         end
    //     endcase
    // end

    

endmodule