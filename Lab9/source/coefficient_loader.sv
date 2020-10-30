module coefficient_loader (
    input wire clk,
    input wire n_reset,
    input wire new_coefficient_set,
    input wire modwait,
    output reg load_coeff,
    output reg [1:0] coefficient_num
);
    typedef enum logic [3:0] { 
        idle,
        load1,
        wait1,
        load2,
        wait2,
        load3,
        wait3,
        load4,
        wait4
    } state_type;

    state_type state, next_state;

    always_ff @(posedge clk, negedge n_reset) begin: State_Reg
        if (n_reset == 1'b0) begin
            state <= idle;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin: Next_State_logic
        next_state = state;
        case (state)
            idle: begin
                if (new_coefficient_set && !modwait) begin
                    next_state = load1;
                end
            end

            load1: begin
                next_state = wait1;
            end

            wait1: begin
                if (!modwait) begin
                    next_state = load2;
                end
            end

            load2: begin
                next_state = wait2;
            end

            wait2: begin
                if (!modwait) begin
                    next_state = load3;
                end
            end 

            load3: begin
                next_state = wait3;
            end

            wait3: begin
                if (!modwait) begin
                    next_state = load4;
                end
            end

            load4: begin
                next_state = wait4;
            end

            wait4: begin
                next_state = idle;
            end
        endcase
    end

    always_comb begin: Output_logic
        load_coeff = '0;
        coefficient_num = '0;

        case (state)
            load1: begin
                load_coeff = 1'b1;
                coefficient_num = 2'b00;
            end

            load2: begin
                load_coeff = 1'b1;
                coefficient_num = 2'b01;
            end

            load3: begin
                load_coeff = 1'b1;
                coefficient_num = 2'b10;
            end

            load4: begin
                load_coeff = 1'b1;
                coefficient_num = 2'b11;
            end
        endcase
    // load_coeff = 1;
	// coefficient_num = 2'b00;

	// case(state)
    //     idle: begin
    //         load_coeff = 0;
    //     end
    //     load1: begin
    //         coefficient_num = 2'b00;
    //     end
    //     wait1: begin
    //         load_coeff = 0;
    //         coefficient_num = 2'b00;
    //     end
    //     load2: begin
    //         coefficient_num = 2'b01;
    //     end
    //     wait2: begin
    //         load_coeff = 0;
    //         coefficient_num = 2'b01;
    //     end
    //     load3: begin
    //         coefficient_num = 2'b10;
    //     end
    //     wait3: begin
    //         load_coeff = 0;
    //         coefficient_num = 2'b10;
    //     end
    //     load4: begin
    //         coefficient_num = 2'b11;
    //     end 
	// endcase
    end

endmodule