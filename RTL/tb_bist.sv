module bist_tb();
    timeunit 1ns/1ns;
    // Parameters
    localparam int size = 8;
    localparam int length = 8;
    localparam int CLK_PERIOD = 5;
    localparam int CLK_MARCH = 1300;//5*256 which is the clock for a whole ram address

    // Signals
    logic start, rst, clk, clk_march,csin, rwbarin, opr;
    logic [size-1:0] address;
    logic [length-1:0] datain, dataout;
    logic [11:0]q;
    logic fail;

    // Clock generation
    always begin
        #CLK_PERIOD clk = ~clk; 
    end
    always begin
        #CLK_MARCH clk_march = ~clk_march; 
    end

    // DUT instantiation
    BIST #(
        .size(size),
        .length(length)
    ) DUT (
        .start(start),
        .rst(rst),
        .clk(clk),
	.clk_march(clk_march),
        .csin(csin),
        .rwbarin(rwbarin),
        .opr(opr),
        .address(address),
        .datain(datain),
        .dataout(dataout),
	.q(q),
        .fail(fail)
    );

    initial begin

        // initialize fsdb dump file
        $fsdbDumpfile("bist.fsdb");
        $fsdbDumpvars();

        // Initialize signals
        start = 0;
        rst = 1;
        clk = 1;
	clk_march=1;
        csin = 0;
        rwbarin = 0;
        opr = 1;
        address = 0;
        datain = 0;

        // Apply reset
        #CLK_PERIOD rst = 0;

        // Perform BIST tests
        #10 start = 1;
        
        if (fail) begin
            if (dataout == 8'bzzzzzzzz) begin
                $display("BIST test completed without errors. ");
                $finish;
            end else begin
                $display("BIST test failed. ");
                $finish;
            end
        end
        
        // Simulation duration
        #90000 $finish;
    end

endmodule

