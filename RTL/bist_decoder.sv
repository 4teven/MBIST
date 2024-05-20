
module bist_decoder (
	input clk,clk_march,rst,
        input logic [2:0] q, // 3-bit selector input
        output logic [7:0] data_t,// 7-bit test pattern output
	output logic reset
        //output logic inde//flag to indicate whether to increase the address or decrease
    );
    timeunit 1ns/1ns;
    // State transition and output logic
    typedef enum {
        IDLE,
        W0, W1, W0_1,W1_1,W0_2,W1_2,W0_3,W1_3,W0_4,W1_4,W0_5,// States for March A
        W0_C, W1_C, W0_C1, W1_C1,W0_C2 // States for March C-
    } march_state_t;

    march_state_t state,next_state;
    // State transition and output logic
    always_ff @(posedge clk_march or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end
    // This module decodes the 3-bit selector into a 7-bit test pattern
    // which is output.
    always_comb begin
        case(q)
            // Checkerboard pattern
            3'b000:begin
                data_t = 8'b10101010;
		reset = 0;
	    end
            3'b001:begin
                data_t = 8'b01010101;
		reset = 0;
	    end
            // Reverse checkerboard pattern
            3'b010:begin
                data_t = 8'b11110000;reset=0;
            end
	    3'b011:begin
                data_t = 8'b00001111;reset=0;
		end
            // BLANKET 0
            3'b100:begin
                data_t = 8'b00000000; reset=0;// Write 0
		end
            // BLANKET 1
            3'b101:begin
                data_t = 8'b11111111; reset=0;// Write 1
		end
            // March A
            3'b110:begin
                case(state)
	            IDLE:begin
                        next_state=W0; reset=0;
                    end 
                    W0:begin
                        next_state=W1;
                        data_t =8'b00000000;reset=1; // Write 0
                    end
                    W1:begin
                        next_state=W0_1;
                        data_t =8'b11111111; reset=1; // Write 1
                    end
                    W0_1:begin
                        next_state=W1_1;
                        data_t =8'b00000000; reset=1; // Write 0
                    end
                    W1_1:begin
                        next_state=W0_2;
                        data_t =8'b11111111; reset=1; // Write 1
                    end
                    W0_2:begin
                        next_state=W1_2;
                        data_t =8'b00000000; reset=1; // Write 0
                    end
                    W1_2:begin
                        next_state=W0_3;
                        data_t =8'b11111111; reset=1; // Write 1
                    end
                    W0_3:begin
                        next_state=W1_3;
                        data_t =8'b00000000; reset=1; // Write 0
                    end
                    W1_3:begin
                        next_state=W0_4;
                        data_t =8'b11111111; reset=1; // Write 1
                    end
                    W0_4:begin
                        next_state=W1_4;
                        data_t =8'b00000000; reset=1; // Write 0
                    end
                    W1_4:begin
                        next_state=W0_5;
                        data_t =8'b11111111; reset=1; // Write 1
                    end
                    W0_5:begin
                        next_state=IDLE;
                        data_t =8'b00000000; reset=0; // Write 0
                    end
                    default:begin
                        next_state = IDLE;reset=0;
			end
                endcase
            end
	    3'b111:begin
                case(state)
		    IDLE:begin
                        next_state=W0_C; reset=0;
                    end 
		    W0_C:begin
                        next_state=W1_C;
                        data_t =8'b00000000; reset=1; // Write 0 in any direction
                    end
                    W1_C:begin
                        next_state=W0_C1;
                        data_t =8'b11111111; reset=1; // Write 1
                    end
                    W0_C1:begin
                        next_state=W1_C1;
                        data_t =8'b00000000; reset=1; // Write 0
                    end
                    W1_C1:begin
                        next_state=W0_C2;
                        data_t =8'b11111111; reset=1; // Write 1
                    end
                    W0_C2:begin
                        next_state=IDLE;
                        data_t =8'b00000000; reset=0; // Write 0
                    end
                    default:begin
                        next_state = IDLE;reset=0;
			end
                endcase
            end
            default:begin
                data_t = 8'bzzzzzzzz;
		end
        endcase
    end

endmodule
