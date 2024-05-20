module tb_bist_counter();
    timeunit 1ns/1ns;
    // Parameters
    parameter int LENGTH = 12;

    // Testbench signals
    logic clk;
    logic ld;
    logic cen;
    logic reset;
    logic [LENGTH-1:0] d_in;
    logic [LENGTH-1:0] q;
    logic cout;

    // Instantiate bist_counter
    bist_counter #(LENGTH) uut (
        .d_in(d_in),
        .clk(clk),
        .ld(ld),
        .cen(cen),
	.reset(reset),
        .q(q),
        .cout(cout)
    );

    // Clock generation
    initial begin
	clk <= 0;
        forever #5 clk = ~clk;
    end

    // Test sequences
    initial begin

        // initialize fsdb dump file
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars();
        
        // Initialize inputs
        d_in = 12'd5;
        ld = 1'b0;
        cen = 1'b0;
	reset=1'b0;

        #10; // Wait for a bit

        // Test case 1: Load
        d_in = 12'b110011111100;
        ld = 1'b1;
        cen = 1'b1;

        #10; // Wait for a bit
        ld = 1'b0;
	reset=1'b1;
        #5000; // Wait for a bit
	reset=1'b0;
        #100; // Wait for a bit

        $finish; // End the simulation
    end

    // Monitor to observe the outputs
    initial begin
        $monitor("At time %0dns: q = %b, cout = %b", $time, q, cout);
    end

endmodule

