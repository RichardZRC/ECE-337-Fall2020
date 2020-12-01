module shift_register (
    input wire shift_enable,
    input wire d_orig,
    input wire clk,
    input wire n_rst,
    input wire clear,
    input wire stuff_bit,
    output reg [15:0] rcv_data,
    output reg one_byte,
    output reg two_byte
);

    reg [15:0] temp_reg;
    reg shift_reserve1, shift_reserve2;
    reg cancel;
    wire reg_shift;

    typedef enum logic [3:0] { 
        idle,
        stuff_bit_delay1,
        stuff_bit_delay2,
        stuff_bit_cancel
    } state_type;
    state_type state, next_state;

    always_comb begin
        next_state = state;
        case(state)
            idle: begin
                if (stuff_bit) begin
                    next_state = stuff_bit_delay1;
                end
            end

            stuff_bit_delay1: begin
                if (shift_enable) begin
                    next_state = stuff_bit_cancel;
                end
            end

            stuff_bit_cancel: begin
                if(shift_enable) begin
                    next_state = idle;
                end
            end
        endcase
    end

    always_comb begin
        cancel = 1'b0;
        if (state == stuff_bit_cancel) begin
            cancel = 1'b1;
        end
    end

    assign reg_shift = shift_enable && ~cancel;

    always_ff @(posedge clk, negedge n_rst) begin: SHIFT_REG
        if (n_rst == 1'b0) begin
            shift_reserve1 <= '0;
            shift_reserve2 <= '0;
            state <= idle;
        end else begin
            shift_reserve2 <= shift_reserve1;
            shift_reserve1 <= reg_shift;
            state <= next_state;
        end
    end
    flex_stp_sr #(.NUM_BITS(16), .SHIFT_MSB(0)) SR (
        .clk(clk),
        .n_rst(n_rst),
        .serial_in(d_orig),
        .shift_enable(shift_reserve2),
        .parallel_out(rcv_data)
    );

    flex_counter #(.NUM_CNT_BITS(4)) BIT_COUNTER_ONE_BYTE (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(shift_reserve2),
        .rollover_val(4'b1000),
        .count_out(bit_count),
        .rollover_flag(one_byte)
    );

    flex_counter #(.NUM_CNT_BITS(5)) BIT_COUNTER_TWO_BYTE (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(shift_reserve2),
        .rollover_val(5'b10000),
        .count_out(bit_count),
        .rollover_flag(two_byte)
    );

    // assign rcv_data = temp_reg[15:8];

endmodule