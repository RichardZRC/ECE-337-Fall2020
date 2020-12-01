module timer (
    input wire clk,
    input wire n_rst,
    input wire stuff_bit,
    input wire enable,
    input wire clear,  // from rcu??? need this???
    output wire shift,
    output reg one_byte_time 
);
    reg [3:0] clk_count1, clk_count2;
    reg [3:0] bit_count1, bit_count2;
    reg state, next_state, cancel_next;
    reg clk_rollover_flag;
    reg bit_rollover_flag;
    wire shift2, shift3;
    wire timer_clear;
    wire timer_enable;
    
    assign timer_enable = enable;

    localparam IDLE = 1'b0;
    localparam CANCEL = 1'b1;

    flex_counter #(.NUM_CNT_BITS(4)) CLK_COUNTER (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(enable),
        .rollover_val(4'b1000),
        .count_out(clk_count1),
        .rollover_flag(clk_rollover_flag)
    );

    assign shift = (clk_count1 == 4'd1);

    flex_counter #(.NUM_CNT_BITS(4)) BIT_COUNTER (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(shift),
        .rollover_val(4'b1000),
        .count_out(bit_count1),
        .rollover_flag()
    );

    flex_counter #(.NUM_CNT_BITS(4)) CLK_COUNTER_2 (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(timer_enable),
        .rollover_val(4'b1000),
        .count_out(clk_count2),
        .rollover_flag()
    );

    flex_counter #(.NUM_CNT_BITS(4)) BIT_COUNTER_2 (
        .clk(clk),
        .n_rst(n_rst),
        .clear(clear),
        .count_enable(shift3),
        .rollover_val(4'b1000),
        .count_out(bit_count2),
        .rollover_flag(one_byte_time)
    );

    assign shift2 = (clk_count2 == 4'd1);
    assign shift3 = shift2 && (~cancel_next);

    always_comb begin
        next_state = state;
        case(state)
            IDLE: begin
                if (stuff_bit) begin
                    next_state = CANCEL;
                end
            end

            CANCEL: begin
                if (shift2) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    always_comb begin
        cancel_next = 1'b0;
        if (CANCEL) begin
            cancel_next = 1'b1;
        end
    end

    always_ff @(posedge clk, negedge n_rst) begin
        if (n_rst == 1'b0) begin
            state <= '0;
        end else begin
            state <= next_state;
        end
    end
endmodule