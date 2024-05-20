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
