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

