module rcu (
    input wire clk,
    input wire n_rst,
    input wire shift_enable,
    input wire eop,
    input wire edge,
    input wire one_byte,
    input wire crc5_err,
    input wire crc16_err,
    input wire [7:0] rcv_data,
    output reg store_rx_packet,
    output reg [2:0] rx_packet,
    output reg receiving,
    output reg w_enable_buffer,
    output reg r_error,
    output reg timer_clear,
    output reg packet_done
);
    typedef enum logic [3:0] { 
        idle,
        load_sync,
        load_pid,
        data_state,
        token,
        token_number,
        error_state,
        wait_eop,
        transfer_done
    } state_type;
    state_type state, next_state;

    localparam idle_packet = 3'b000;
    localparam IN = 3'b001;
    localparam OUT = 3'b010;
    localparam DATA = 3'b011;
    localparam ACK = 3'b100;
    localparam NAK = 3'b101;
    localparam ERROR = 3'b110;
    reg [2:0] next_rx_packet;
    reg temp_ref_last_bit, ref_last_bit, write_enable_fifo, next_write_enable_fifo;
    wire next_store_rx_packet;

    always_ff @(posedge clk, negedge n_rst) begin: STATE_REG
        if (n_rst == 1'b0) begin
            state <= idle;
            rx_packet <= '0;
            ref_last_bit <= '0;
            write_enable_fifo <= '0;
            store_rx_packet <= '0;
        end else begin
            state <= next_state;
            rx_packet <= next_rx_packet;
            ref_last_bit <= temp_ref_last_bit;
            write_enable_fifo <= next_write_enable_fifo;
            store_rx_packet <= next_store_rx_packet;
        end
    end

    

    always_comb begin: NEXT_STATE_LOGIC
        next_state = state;
        next_rx_packet = rx_packet;
        temp_ref_last_bit = ref_last_bit;
        case(state) 
            idle: begin
                if (edge) begin
                    next_state = load_sync;
                end
            end

            load_sync: begin
                if (one_byte) begin
                    if (rcv_data == 8'b00000001) begin
                        next_state = load_pid;
                    end else begin
                        next_state = error_state;
                    end
                end
            end

            load_pid: begin
                if (one_byte) begin
                    if (rcv_data[3:0] == 4'b0001) begin
                        next_state = token;
                        next_rx_packet = OUT;
                    end else if (rcv_data[3:0] == 4'b1001) begin
                        next_state = token;
                        next_rx_packet = IN;
                    end else if ((rcv_data[3:0] == 4'b0011) || (rcv_data[3:0] == 4'b1011)) begin
                        next_state = data;
                    end else if (rcv_data[3:0] == 4'b0010) begin
                        next_state = wait_eop;
                        next_rx_packet = ACK;
                    end else if (rcv_data[3:0] == 4'b1010) begin
                        next_state = wait_eop;
                        next_rx_packet = NAK;
                    end else begin
                        next_state = error_state;
                        next_rx_packet = ERROR;
                    end
                end
            end

            token: begin
                if (one_byte) begin
                    if (rcv_data[6:0] != 7'b1110000) begin
                        next_state = wait_eop;
                    end else begin
                        temp_ref_last_bit = rcv_data[7];
                        next_state = token_number;
                    end
                end
            end

            token_number: begin
                if (one_byte) begin
                    if ({rcv_data[2:0], ref_last_bit} != 4'b0100) begin
                        next_state = wait_eop;
                    end
                    if (eop) begin
                        if (crc5_err) begin
                            next_state = error_state;
                        end else begin
                            next_state = transfer_done;
                        end
                    end
                end
            end

            data_state: begin
                if (eop) begin
                    if (one_byte && !crc16_err) begin
                        next_state = transfer_done;
                    end else begin
                        next_state = error_state;
                    end
                end
            end

            error_state: begin
                if (edge) begin
                    next_state = load_sync;
                end
            end

            wait_eop: begin
                if (eop) begin
                    next_state = transfer_done;
                end
            end

            transfer_done: begin
                if (edge) begin
                    next_state = load_sync;
                end
            end

        endcase
    end

    assign next_store_rx_packet = !write_enable_fifo && next_write_enable_fifo;

    always_comb begin: OUTPUT_LOGIC
        receiving = '0;
        next_write_enable_fifo = 1'b0;
        w_enable_buffer = '0;
        timer_clear = '0;
        r_error = '0;
        packet_done = '0;
        case (state)
            load_sync: begin
                receiving = 1'b1;
            end

            load_pid: begin
                receiving = 1'b1;
            end

            data_state: begin
                receiving = 1'b1;
                if (one_byte && !eop) begin
                    w_enable_buffer = 1'b1;
                    next_write_enable_fifo = 1'b1;
                end
            end

            token: begin
                receiving = 1'b1;
            end

            token_number: begin
                receiving = 1'b1;
            end

            error_state: begin
                r_error = 1'b1;
            end

            wait_eop: begin
                receiving = 1'b1;
            end

            transfer_done: begin
                timer_clear = 1'b1;
                packet_done = 1'b1;
            end
        endcase
    end


endmodule