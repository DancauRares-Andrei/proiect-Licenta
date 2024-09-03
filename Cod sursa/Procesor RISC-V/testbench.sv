module testbench;
  reg clk;
  reg reset;
  reg [31:0] instruction;
  wire [63:0] result;

  processor dut (
      .clk(clk),
      .reset(reset),
      .instruction(instruction),
      .result(result)
  );

  always begin
    clk = 1;
    #5;
    clk = 0;
    #5;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    reset = 1;
    #10;
    reset = 0;  //Momentul 10
    #10;

    //Momentul 20      
    //addi ra, zero, 10     
    //Verificare: result=a la momentul 30
    instruction = 32'h00A00093;
    #20;

    //Momentul 40
    //addi sp, ra, 20 
    //Verificare: result=1e la momentul 50
    instruction = 32'h01408113;
    #20;

    //Momentul 60
    //add gp, ra, sp 
    //Verificare: result=28 la momentul 70
    instruction = 32'h002081B3;
    #20;

    //Momentul 80
    //sub tp, gp, sp 
    //Verificare: result=a la momentul 90
    instruction = 32'h40218233;
    #20;

    //Momentul 100
    //lui t0, 100 
    //Verificare: result=64000 la momentul 110
    instruction = 32'h000642B7;
    #20;

    //Momentul 120
    // addi t1, zero, 50 
    //Verificare: result=32 la momentul 130
    instruction = 32'h03200313;
    #20;

    //Momentul 140
    //and t2, t0, t1 
    //Verificare: result=0 la momentul 150
    instruction = 32'h0062F3B3;
    #20;

    //Momentul 160
    //or t3, t2, t0 
    //Verificare: result=64000 la momentul 170
    instruction = 32'h0053EE33;
    #20;

    //Momentul 180
    //xor t4, t3, t2 
    //Verificare: result=64000 la momentul 190
    instruction = 32'h007E4EB3;
    #20;

    //Momentul 200
    //andi t5, t4, 3 
    //Verificare: result=0 la momentul 210
    instruction = 32'h003EFF13;
    #20;

    //Momentul 220
    //ori t6, t5, 6 
    //Verificare: result=6 la momentul 230
    instruction = 32'h006F6F93;
    #20;

    //Momentul 240
    //xori s0, t6, 9 
    //Verificare: result=f la momentul 250
    instruction = 32'h009FC413;
    #20;

    //Momentul 260
    // srli s1, s0, 2 
    //Verificare: result=3 la momentul 270
    instruction = 32'h00245493;
    #20;

    //Momentul 280
    //sll s2, s1, s1 
    //Verificare: result=18 la momentul 290
    instruction = 32'h00949933;
    #20;

    //Momentul 300
    //srl s3, s2, s1 
    //Verificare: result=3 la momentul 310
    instruction = 32'h009959B3;
    #20;

    //Momentul 320
    //slli s1, s0, 2 
    //Verificare: result=3c la momentul 330
    instruction = 32'h00241493;
    #20;

    //Momentul 340
    //sw gp, 0(zero) 
    //Verificare: result=28 la momentul 350
    instruction = 32'h00302023;
    #20;

    //Momentul 360
    //lw a0, 0(zero) 
    //Verificare: result=28 la momentul 370
    instruction = 32'h00002503;
    #20;

    //Momentul 380
    //slt t0, sp, ra 
    //Verificare: result=0 la momentul 390
    instruction = 32'h001122B3;
    #20
      //Momentul 400
      //sltu t1, gp, s1
      //Verificare: result=1 la momentul 410
      instruction = 32'h0091B333;
    #20
      //Momentul 420
      //sra t2,s0,t1
      //Verificare: result=7 la momentul 430
      instruction = 32'h406453B3;
    #20
      //Momentul 440
      //slti a3,s1,45
      //Verificare: result=0 la momentul 450
      instruction = 32'h02D4A693;
    #20
      //Momentul 460
      //sltiu s2, s3, 4
      //Verificare: result=1 la momentul 470
      instruction = 32'h0049B913;
    #20
      //Momentul 480
      //srai a5, a0, 2
      //Verificare: result=a la momentul 490
      instruction = 32'h40255793;
    #20
      //Momentul 500
      //sb s3, 4(zero)
      //Verificare: result=3 la momentul 510
      instruction = 32'h01300223;
    #20
      //Momentul 520
      //sh s0, 8(zero)
      //Verificare: result=f la momentul 530
      instruction = 32'h00801423;
    #20
      //Momentul 540
      //sd t3, 12(zero)
      //Verificare: result=64000 la momentul 550
      instruction = 32'h01C03623;
    #20
      //Momentul 560
      //lb s9, 4(zero)
      //Verificare: result=3 la momentul 570
      instruction = 32'h00400c83;
    #20
      //Momentul 580
      //lh s7, 8(zero)
      //Verificare: result=f la momentul 590
      instruction = 32'h00801b83;
    #20
      //Momentul 600
      //lbu t5, 4(zero)
      //Verificare: result=3 la momentul 610
      instruction = 32'h00404F03;
    #20
      //Momentul 620
      //lhu s7, 8(zero)
      //Verificare: result=f la momentul 630
      instruction = 32'h00805B83;
    #20
      //Momentul 640
      //lwu a0, 0(zero) 
      //Verificare: result=28 la momentul 650
      instruction = 32'h00006503;
    #20
      //Momentul 660
      //ld t3, 12(zero)
      //Verificare: result=64000 la momentul 670
      instruction = 32'h00C03E03;
    #20
      //Momentul 680
      //jal s7, 400
      //Verificare: result=114 la momentul 690
      instruction = 32'h19000BEF;
    #20
      //Momentul 700
      //jalr s10, a5, 100
      //Verificare: result=72 la momentul 720
      instruction = 32'h06478D67;
    #20
      //Momentul 720
      //auipc s1, 20
      //Verificare: result=1406e la momentul 730
      instruction = 32'h00014497;
    #20
      //Momentul 740
      //beq sp,gp,100
      //Verificare: pc=7a la momentul 750
      instruction = 32'h06310263;
    #20
      //Momentul 760
      //bne s1,a0,45
      //Verificare: pc=aa la momentul 770
      instruction = 32'h02A49663;
    #20
      //Momentul 780
      //blt s1,a0, 10
      //Verificare: pc=b8 la momentul 790
      instruction = 32'h00A4C563;
    #20
      //Momentul 800
      //bge gp,a5,999
      //Verificare: pc=4a2 la momentul 810
      instruction = 32'h3EF1D363;
    #20
      //Momentul 820
      //bltu s1,a0, 10
      //Verificare: pc=4b0 la momentul 830
      instruction = 32'h00a4e563;
    #20
      //Momentul 840
      //bgeu gp,a5,999
      //Verificare: pc=89a la momentul 850
      instruction = 32'h3EF1F363;
    #20 $finish;
  end
endmodule
