module RISCVProcessor_tb;

    reg clk;
    reg reset;
    reg CLK_BUTT;
  wire [15:0] result;

    // Instantierea modulului principal al procesorului
    RISCVProcessor dut(
        .clk(clk),
        .reset(reset),
      .CLK_BUTT(CLK_BUTT),
      .result(result)
    );

    // Generare semnal clock
    always #5 clk = ~clk;
	always #10 CLK_BUTT=~CLK_BUTT;
    initial begin
        // Initializarea semnalelor de intrare
        //reset = 0;
        clk = 0;
		CLK_BUTT=0;
      reset=0;
        //reset=1;
        // Pregatirea fisierului vcd
        $dumpfile("simulation.vcd");
        $dumpvars;
     /* #120 reset=1;
      #10 reset=0;*/
        // Oprirea simularii
        #3600 $finish;
    end

endmodule
