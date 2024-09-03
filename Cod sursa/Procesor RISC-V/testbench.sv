module RISCVProcessor_tb;

    reg clk;
    reg reset;
  wire [15:0] result;

    // Instantierea modulului principal al procesorului
    RISCVProcessor dut(
        .clk(clk),
        .reset(reset),
      .result(result)
    );

    // Generare semnal clock
    always #5 clk = ~clk;

    initial begin
        // Initializarea semnalelor de intrare
        reset = 0;
        clk = 0;

        // Pregatirea fisierului vcd
        $dumpfile("simulation.vcd");
        $dumpvars;


        // Oprirea simularii
        #1800 $finish;
    end

endmodule
