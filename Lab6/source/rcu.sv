module rcu (
    input wire clk,
    input wire n_rst,
    input wire start_bit_detected,
    input wire packet_done,
    input wire framing_error,
    output reg sbc_clear,
    output reg sbc_enable,
    output reg load_buffer,
    output reg enable_timer
);

    localparam [2:0] Idle = 3'b000;
    localparam [2:0] ReadingBit = 3'b001;
    localparam [2:0] DataReady = 3'b010;
    localparam [2:0] Waiting = 3'b011;
    localparam [2:0] LoadData = 3'b100;

    reg [2:0] state, next_state;

    always_ff @ (posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            state <= Idle;
        end else begin
            state <= next_state;
        end
    end 

    always_comb begin
        next_state = state;
        case (state)
            Idle: begin
                if (start_bit_detected) begin
                    next_state = ReadingBit;
                end
            end

            ReadingBit: begin
                if (packet_done) begin
                    next_state = DataReady;
                end
            end

            DataReady: begin
                next_state = Waiting;
            end

            Waiting: begin
                if (framing_error) begin
                    next_state = Idle;
                end else begin
                    next_state = LoadData;
                end
            end

            LoadData: begin
                next_state = Idle;
            end
        endcase
    end

    always_comb begin
        sbc_clear = 1'b0;
        sbc_enable = 1'b0;
        enable_timer = 1'b0;
        load_buffer = 1'b0;

        case (state)
             ReadingBit: begin
                 sbc_clear = 1'b1;
                 enable_timer = 1'b1;
             end

             DataReady: begin
                 sbc_enable = 1'b1;
             end

             LoadData: begin
                 load_buffer = 1'b1;
             end
        endcase
    end

endmodule