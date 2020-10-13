module controller (
    input wire clk,
    input wire n_rst,
    input wire dr,
    input wire lc,
    input wire overflow,
    output reg cnt_up,
    output reg clear,
    output reg modwait,
    output reg err,
    output reg [3:0] src1,
    output reg [3:0] src2,
    output reg [2:0] op,
    output reg [3:0] dest
);

    typedef enum logic [4:0] {
        idle,
        eidle,
        store_data,
        load_zero,
        sort1,
        sort2,
        sort3,
        sort4,
        mul1,
        sub1,
        mul2,
        add1,
        mul3,
        sub2,
        mul4,
        add2,
        store_coeff1,
        wait_coeff1,
        store_coeff2,
        wait_coeff2,
        store_coeff3,
        wait_coeff3,
        store_coeff4
    } state_type;

    state_type state, next_state;

    always_ff @(posedge clk, negedge n_rst) begin: reg
        if (n_rst == 1'b0) begin
            state <= '0;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin: next_state_logic
        next_state = state;
        case (state)
            idle: begin
                if (dr) begin
                    next_state = store_data;
                end else if (lc) begin
                    next_state = store_coeff1;
                end
            end

            store_data: begin
                if (!dr) begin
                    next_state = eidle;
                end else begin
                    next_state = load_zero;
                end
            end

            eidle: begin
                if (dr) begin
                    next_state = store_data;
                end
            end

            load_zero: begin
                next_state = sort1;
            end

            sort1: begin
                next_state = sort2;
            end

            sort2: begin
                next_state = sort3;
            end

            sort3: begin
                next_state = sort4;
            end

            sort4: begin
                next_state = mul1;
            end

            mul1: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = sub1;
                end
            end

            sub1: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = mul2;
                end
            end

            mul2: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = add1;
                end
            end

            add1: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = mul3;
                end
            end

            mul3: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = sub2;
                end
            end

            sub2: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = mul4;
                end
            end

            mul4: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = add2;
                end
            end

            add2: begin
                if (overflow) begin
                    next_state = eidle;
                end else begin
                    next_state = idle;
                end
            end

            store_coeff1: begin
                next_state = wait_coeff1;
            end

            wait_coeff1: begin
                if (lc) begin
                    next_state = store_coeff2;
                end
            end

            store_coeff2: begin
                next_state = wait_coeff2;
            end

            wait_coeff2: begin
                if (lc) begin
                    next_state = store_coeff3;
                end
            end

            store_coeff3: begin
                next_state = wait_coeff3;
            end

            wait_coeff3: begin
                if (lc) begin
                    next_state = store_coeff4;
                end
            end

            store_coeff4: begin
                next_state = idle;
            end
        endcase
    end
    
    always_comb begin: output_logic
        cnt_up = '0;
        clear = '0;
        modwait = '0;
        err = '0;
        src1 = '0;
        src2 = '0;
        op = '0;
        dest = '0;

        case (state)
            idle: begin
                modwait = 1'b0;
            end

            store_data: begin
                op = 3'b010;
                dest = 4'd5;
                err = 0;
                modwait = 1;
            end

            eidle: begin
                err = 1;
                modwait = 0;
            end

            load_zero: begin
                op = 3'b101;
                dest = 0;
                src1 = 0;
                src2 = 0;
                cnt_up = 1;
                modwait = 1;
            end

            sort1: begin
                op = 3'b001;
                dest = 3'd1;
                src1 = 3'd2;
                cnt_up = 0;
                modwait = 1;
            end

            sort2: begin
                op = 3'b001;
                dest = 3'd2;
                src1 = 3'd3;
                modwait = 1;
            end

            sort3: begin
                op = 3'b001;
                dest = 3'd3;
                src1 = 3'd4;
                modwait = 1;
            end

            sort4: begin
                op = 3'b001;
                dest = 3'd4;
                src1 = 3'd5;
                modwait = 1;
            end

            mul1: begin
                op = 3'b110;
                dest = 3'd10;
                src1 = 3'd6;
                src2 = 3'd1;
                modwait = 1;
            end

            sub1: begin
                op = 3'b101;
                dest = 3'd0;
                src1 = 3'd0;
                src2 = 1010;
                modwait = 1;
            end

            mul2: begin
                op = 3'b110;
                dest = 3'd10;
                src1 = 3'd7;
                src2 = 3'd2;
                modwait = 1;
            end

            add1: begin
                op = 3'b100;
                dest = 3'd0;
                src1 = 3'd0;
                src2 = 1010;
                modwait = 1;
            end

            mul3: begin
                op = 3'b110;
                dest = 3'd10;
                src1 = 3'd8;
                src2 = 3'd3;
                modwait = 1;
            end

            sub2: begin
                op = 3'b101;
                dest = 3'd0;
                src1 = 3'd0;
                src2 = 1010;
                modwait = 1;
            end

            mul4: begin
                op = 3'b110;
                dest = 3'd10;
                src1 = 3'd9;
                src2 = 3'd4;
                modwait = 1;
            end

            add2: begin
                op = 3'b100;
                dest = 3'd0;
                src1 = 3'd0;
                src2 = 1010;
                modwait = 1;
            end

            store_coeff1: begin
                op = 3'b011;
                dest = 3'd6;
                modwait = 1;
                clear = 1;
            end

            wait_coeff1: begin
                modwait = 0;
                clear = 0;
            end

            store_coeff2: begin
                op = 3'b011;
                dest = 3'd7;
                modwait = 1;
            end

            wait_coeff2: begin
                modwait = 0;
            end

            store_coeff3: begin
                op = 3'b011;
                dest = 3'd8;
                modwait = 1;
            end

            wait_coeff3: begin
                modwait = 0;
            end

            store_coeff4: begin
                op = 3'b011;
                dest = 3'd9;
                modwait = 1;
            end
        endcase
    end
    

endmodule