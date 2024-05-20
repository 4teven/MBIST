module tb_bist_comparator();
    timeunit 1ns/1ns;
    // Testbench signals
    logic [7:0] data_t;
    logic [7:0] ramout;
    logic clk;
    logic gt;
    logic eq;
    logic lt;

    // Instantiate bist_comparator
    bist_comparator uut (
        .data_t(data_t),
        .ramout(ramout),
        .gt(gt),
        .eq(eq),
        .lt(lt)
    );  
    initial begin
	clk<=0;
	forever #5 clk<=~clk;
    end

    initial begin

        // initialize fsdb dump file
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars();

        data_t = 8'b00000000;
        ramout = 8'b00000000;

        #10;
        data_t = 8'b00010000;
        ramout = 8'b00000000;

        #10;
        data_t = 8'b0010000;
        ramout = 8'b0000000;

        #10;
        data_t = 8'b00100000;
        ramout = 8'b00010000;

        #10;
        data_t = 8'b00100000;
        ramout = 8'b00110000;

        #10;
        data_t = 8'b01010000;
        ramout = 8'b01010000;

        #10;
        data_t = 8'b10100000;
        ramout = 8'b10100000;

        #10;
        data_t = 8'b11110000;
        ramout = 8'b11110000;

        $finish; // End the simulation
    end

endmodule

