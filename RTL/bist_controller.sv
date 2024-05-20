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


