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
    always_ff @(posedge clk)
    begin
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

