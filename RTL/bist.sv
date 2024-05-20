module BIST #(
        parameter int size = 8,
        parameter int length = 8
    ) (
        input logic start, rst, clk,clk_march, csin, rwbarin, opr, //input signals
        input logic [size-1:0] address,                  //input address
        input logic [length-1:0] datain,                 //input data
        output logic [length-1:0] dataout,
	output logic [11:0] q,               //output data
        output logic fail                               //output fail
    );
    timeunit 1ns/1ns;
    logic cout, ld, NbarT, u_d,reset,rwbar, gt, eq, lt;
    logic [11:0] q;
    logic [7:0] data_t;
    logic [length-1:0] ramin, ramout;
    logic [size-1:0] ramaddr;
    logic [11:0]zero= 12'b0; //initial value of zero
    // logic u_d=(q[10]&q[9]&~q[8])
    //Counter
    bist_counter CNT (
                     .d_in(zero), 
                     .clk(clk), 
                     .ld(ld), 
                     .cen(1'b1), 
		     .reset(reset),
                     .q(q), 
                     .cout(cout)
                 );

    //Decoder
    bist_decoder DEC (
		     .clk(clk),
		     .clk_march(clk_march),
	  	     .rst(rst),
                     .q(q[11:9]), 
                     .data_t(data_t),
		     .reset(reset)
                 );

    // Instantiate the bist_multiplexer for both address and data
    bist_multiplexer #(
                         .ADDR_WIDTH(size),     // 8-bit address width
                         .DATA_WIDTH(length)    // 8-bit data width
                     ) MUX (
                         .normal_addr(address),
                         .normal_data(datain),
                         .bist_addr(q[7:0]),
                         .bist_data(data_t),
                         .NbarT(NbarT),
                         .mem_addr(ramaddr),
                         .mem_data(ramin)
                     );

    //BIST Controller
    bist_controller CNTRL (
                        .start(start),
                        .rst(rst),
                        .clk(clk),
                        .cout(cout),
                        .NbarT(NbarT),
                        .ld(ld)
                    );

    assign rwbar = (~NbarT) ? rwbarin : q[8];

    //RAM
    bist_sram MEM (
                  .ramaddr(ramaddr),
                  .ramin(ramin),
                  .we(~rwbar),
                  .clk(clk),
                  .ramout(ramout)
              );

    //Comparator
    bist_comparator CMP (
                        .data_t(data_t),
                        .ramout(ramout),
                        .eq(eq),
                        .gt(gt),
                        .lt(lt)
                    );

    always_ff @(posedge clk) begin
        if (NbarT && rwbar && opr && ~eq) begin
            fail <= 1'b1;
        end
        else begin
            fail <= 1'b0;
        end
    end

    assign dataout = ramout;

endmodule


module bist_sram
(
    input logic [7:0] ramaddr,
    input logic [7:0] ramin,
    input logic we, clk,
    output logic [7:0] ramout
);
    timeunit 1ns/1ns;
    /* Declare the RAM variable */
    logic [7:0] ram[255:0];

    /* Variable to hold the registered read address */
    logic [7:0] addr_reg;
    always_ff @(posedge clk) begin
        /* Write */
        if (we)
            ram[ramaddr] <= ramin;
            addr_reg <= ramaddr;
    end
    /* Continuous assignment implies read returns NEW data.
    This is the natural behavior of the TriMatrix memory
    blocks in Single Port mode*/
    assign ramout = ram[addr_reg];

endmodule

module bist_multiplexer #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 8
) (
    input logic [ADDR_WIDTH-1:0] normal_addr,   // Input address for normal mode
    input logic [DATA_WIDTH-1:0] normal_data,   // Input data for normal mode
    input logic [ADDR_WIDTH-1:0] bist_addr,     // Input address for BIST mode
    input logic [DATA_WIDTH-1:0] bist_data,     // Input data for BIST mode
    input logic NbarT,                          // 0: normal mode, 1: test mode
    output logic [ADDR_WIDTH-1:0] mem_addr,     // Output address for memory
    output logic [DATA_WIDTH-1:0] mem_data      // Output data for memory
);
timeunit 1ns/1ns;
// Select between normal and BIST inputs based on the value of NbarT
assign mem_addr = (NbarT == 1'b0) ? normal_addr : bist_addr;
assign mem_data = (NbarT == 1'b0) ? normal_data : bist_data;

endmodule

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

module bist_counter
#(parameter int length = 12)
    (input logic [length-1:0] d_in, // input data
     input logic clk, ld, cen, reset,// control signals
     output logic [length-1:0] q, // output data
     output logic cout); // carry-out
    timeunit 1ns/1ns;
    logic [length:0] cnt_reg; // counter register
    logic u_d=1;
    always@(posedge clk) begin // clocked process
        if (cen) begin // count enable
            if (ld) begin // load
                cnt_reg <= {1'b0, d_in};
            end
            else if (u_d | ~reset) begin 
		if(reset & cnt_reg[7:0]==8'hfe)begin
			u_d<=1'b0;
		end
		cnt_reg<=cnt_reg+1;
            end
	    else begin
		if(reset & cnt_reg[7:0]==8'h01)begin
			u_d<=1'b1;
		end
		cnt_reg<=cnt_reg-1;
            end
        end
    end
	
    assign q = cnt_reg[length-1:0]; // output data
    assign cout = cnt_reg[length]; // carry-out

endmodule

module bist_controller 
(input logic start, rst, clk, cout,
 output logic NbarT, ld
);
    timeunit 1ns/1ns;
    typedef enum logic [2:0] {reset, test} state_t; 
    state_t current; 
    always_ff @(posedge clk) begin
        if (rst) begin
            current <= reset;
        end
        else begin
            case (current)
                reset: begin
                    if (start) begin
                        current <= test;
                    end
                    else begin
                        current <= reset;
                    end
                end
                test: begin
                    if (cout) begin
                        current <= reset;
                    end
                    else begin
                        current <= test;
                    end
                end
                default: begin
                    current <= reset;
                end
            endcase
        end
    end
    assign NbarT = (current == test) ? 1'b1 : 1'b0;
    assign ld = (current == reset) ? 1'b1 : 1'b0;
endmodule


module bist_comparator (
    input logic [7:0] data_t,    // Expected data
    input logic [7:0] ramout,    // Actual data from memory
    output logic gt,       // Greater than
    output logic eq,       // Equal
    output logic lt        // Less than
);
timeunit 1ns/1ns;
// Set the bits to 1 if the relation is true
always_comb begin
    if (data_t > ramout) begin
        gt = 1'b1;
        eq = 1'b0;
        lt = 1'b0;
    end else if (data_t == ramout) begin
        gt = 1'b0;
        eq = 1'b1;
        lt = 1'b0;
    end else if (data_t < ramout) begin
        gt = 1'b0;
        eq = 1'b0;
        lt = 1'b1;
    end else begin
        gt = 1'b0;
        eq = 1'b0;
        lt = 1'b0;
    end
end

endmodule



