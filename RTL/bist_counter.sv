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
		if(reset & cnt_reg[7:0]==8'd254)begin
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

