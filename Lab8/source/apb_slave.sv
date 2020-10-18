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

    typedef enum logic [1:0] { 
        idle,
        eidle,
        configure,
        read
    } state_type;

    state_type state, next_state;
    reg [3:0] next_data_size;
    reg [13:0] next_bit_period;

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            state <= '0;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            data_size <= '0;
        end else begin
            data_size <= next_data_size;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            bit_period <= '0;
        end else begin
            bit_period <= next_bit_period;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            idle: begin
                if (psel && pwrite) begin
                    next_state = configure;
                end else if (psel && !pwrite) begin
                    next_state = read;
                end
            end

            configure: begin
                if (paddr == 0 || paddr == 1 || paddr == 6) begin
                    next_state = eidle;
                end else if (psel && pwrite) begin
                    next_state = configure;
                end else begin
                    next_state = idle;
                end
            end

            read: begin
                if (psel && !pwrite) begin
                    next_state = read;
                end else begin
                    next_state = idle;
                end
            end

            eidle: begin
                if (psel && pwrite) begin
                    next_state = configure;
                end else if (psel && !pwrite) begin
                    next_state = read;
                end
            end
        endcase
    end

    always_comb begin
        next_bit_period = bit_period;
        next_data_size = data_size;
        prdata = '0;
        pslverr = 0;
        data_read = 0;

        case (state)
            configure: begin
                if (penable) begin
                    if (paddr == 2) begin
                        next_bit_period[7:0] = pwdata;
                    end else if (paddr == 3) begin
                        next_bit_period[13:8] = pwdata[5:0];
                    end else if (paddr == 4) begin
                        next_data_size = pwdata[3:0];
                    end
                end
            end

            read: begin
                if (penable) begin
                    if (paddr == 0) begin
                        prdata = data_ready;
                    end else if (paddr == 1) begin
                        if (framing_error) begin
                            prdata = 8'd1;
                        end else if (overrun_error) begin
                            prdata = 8'd2;
                        end else begin
                            prdata = '0;
                        end
                    end else if (paddr == 6) begin
                        data_read = 1;
                        prdata = rx_data;
                    end
                end
            end

            eidle: begin
                pslverr = 1;
            end
        endcase
    end

    

endmodule