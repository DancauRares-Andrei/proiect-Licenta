//De trecut la LE si de modificat instructiunile de load si store sa foloseasca registrii de 8 biti
//Clock controlat de buton
module ClockDivider (
  input wire clk_in,
  input wire CLK_BUTT,
  output reg clk_out
);
  reg [1:0] state;  // Starea automatului pe 2 biti pentru cele trei stări
	initial begin
      state=2'b00;
      clk_out=0;
    end
  always @(posedge clk_in) begin
      // Automatul Moore
      case (state)
        2'b00: state <= (CLK_BUTT) ? 2'b01 : 2'b00;  // Starea 1
        2'b01: state <= (CLK_BUTT) ? 2'b10 : 2'b00;  // Starea 2
        2'b10: state <= (CLK_BUTT) ? 2'b10 : 2'b00;  // Starea 3
      endcase

      // Comutare clock in functie de starea automatului
      case (state)
        2'b00: clk_out <= 1'b0;  // Starea 1, iesire 0
        2'b01: clk_out <= 1'b1;      // Starea 2, iesire 1
        2'b10: clk_out <= 1'b0;  // Starea 3, iesire 0
      endcase
  end
endmodule
//Modificare registru sp si asignare pe 6 biti shamt si instructiuni shiftare
module RISCVProcessor (
    input clk,
    input reset,
    input wire CLK_BUTT,
  output reg [15:0] result
);
  reg[63:0] pc;
  reg[63:0] regdif;
  reg Jump;
  reg[63:0] jumpAddress;
  reg [63:0] registers [0:31];
  reg [63:0] dataMemory[0:128];
  reg [8:0] memory[0:59];
  reg [31:0] instruction;
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg [6:0] funct7;
  reg [11:0] imm12;
  reg [5:0] shamt;//Pentru RV64I, shamt are 6 biti
  reg [4:0] rs1;
  reg [4:0] rs2;
  reg [4:0] rd;
  reg [63:0] regtest;
  integer i;
    initial begin
      //Citirea din fisier a continutului memoriei
      $readmemh("instructions.mem", memory);
      pc = 64'h0; // Initializare cu 0
      //Initializare registrii de lucru
      Jump=0;
      jumpAddress=0;
      regdif=0;
      //Initializare cu 0 banc de registre
        for (i = 0; i <= 31; i = i + 1)
          registers[i] = (i==2)?128:0;
      //Intializare cu 0 memorie de date
      $readmemh("data.mem", dataMemory);
      result=0;
    end
    wire clk_div;
  ClockDivider clk_divider (
    .clk_in(clk),
    .clk_out(clk_div),
    .CLK_BUTT(CLK_BUTT)
  );
  always @(posedge clk_div) begin
    //Calculez noua instructiune si parametrii acesteia
    instruction = {memory[pc][7:0], memory[pc+1][7:0], memory[pc+2][7:0], memory[pc+3][7:0]};
    //Decodific instructiunea
        opcode = instruction[6:0];
      funct3 = instruction[14:12];
      funct7 = instruction[31:25];
      imm12 = instruction[31:20];
      shamt = instruction[25:20];
      rs1 = instruction[19:15];
      rs2 = instruction[24:20];
      rd = instruction[11:7];
    if(!reset) begin
      //Prelucrarea instructiunii
        // Identificarea tipului de instructiune
      case (opcode)
        7'b0110011: begin
           Jump=0;
          // Instructiuni de tip R
          case (funct3)
            3'b000: begin  // ADD, SUB
              if (funct7 == 7'b0000000)
                begin
                  if (rd!=0) begin
                   registers[rd]= registers[rs1] + registers[rs2]; 
                   result=registers[rd]; 
                  end
                  else
                        result=0;
                end
              else if (funct7 == 7'b0100000) 
              begin 
              if (rd!=0) begin
                registers[rd]= registers[rs1] - registers[rs2]; 
                result=registers[rd];      
                end  
                else
                        result=0;  
              end 
            end
            3'b001: begin  // SLL pentru RV64I
               if (rd!=0) begin
                 registers[rd] = registers[rs1] << registers[rs2][5:0];
              result=registers[rd]; end
              else
                        result=0;
            end
            3'b010: begin  // SLT verificat pe cazul numerelor negative
            if (rd!=0) begin
              regdif=registers[rs1] - registers[rs2];
              registers[rd] = regdif[63];
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b011: begin  // SLTU
            if (rd!=0) begin
              registers[rd] = (registers[rs1] < registers[rs2]) ? 1 : 0;
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b100: begin  // XOR
            if (rd!=0) begin
              registers[rd] = registers[rs1] ^ registers[rs2];
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b101: begin
              if (funct7 == 7'b0000000) begin  // SRL pentru RV64I
              if (rd!=0) begin
                registers[rd] = registers[rs1] >> registers[rs2][5:0];
                result=registers[rd]; 
                end
                else
                        result=0;
              end else if (funct7 == 7'b0100000) begin  // SRA pentru RV64I
              if (rd!=0) begin
                registers[rd] = registers[rs1] >>> registers[rs2][5:0];
                result=registers[rd]; 
                end
                else
                        result=0;
              end
            end
            3'b110: begin  // OR
            if (rd!=0) begin
              registers[rd] = registers[rs1] | registers[rs2];
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b111: begin  // AND
            if (rd!=0) begin
              registers[rd] = registers[rs1] & registers[rs2];
              result=registers[rd];
              end
              else
                        result=0; 
            end
            default: result = 0;
          endcase
        end
        7'b0010011: begin
          // Instructiuni de tip I
           Jump=0;
          case (funct3)
            3'b000: begin  // ADDI
            if (rd!=0) begin
              registers[rd] = registers[rs1] + {{52{imm12[11]}},imm12};
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b010: begin  // SLTI 
            if (rd!=0) begin
              regdif=registers[rs1]-{{52{imm12[11]}},imm12};
              registers[rd] = regdif[63];
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b011: begin  // SLTIU
            if (rd!=0) begin
              registers[rd] = (registers[rs1] < {{52{imm12[11]}},imm12}) ? 1 : 0;
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b100: begin  // XORI
            if (rd!=0) begin
              registers[rd] = registers[rs1] ^ {{52{imm12[11]}},imm12}; 
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b110: begin  // ORI
            if (rd!=0) begin
              registers[rd] = registers[rs1] | {{52{imm12[11]}},imm12};
              result=registers[rd]; 
              end
              else
                        result=0;
            end
            3'b111: begin  // ANDI
            if (rd!=0) begin
              registers[rd] = registers[rs1] & {{52{imm12[11]}},imm12};
              result=registers[rd];
              end 
              else
                        result=0;
            end
            3'b001: begin // SLLI
                if (rd!=0) begin
                registers[rd] = registers[rs1] << shamt;
                result=registers[rd]; 
                end
                else
                        result=0;
            end
            3'b101: begin
              if (funct7 == 7'b0000000) 
                begin  // SRLI
                if (rd!=0) begin
                  registers[rd] = registers[rs1] >> shamt;
                  result=registers[rd]; 
                  end
                  else
                        result=0;
                end 
              else if (funct7 == 7'b0100000) 
                begin  // SRAI
                if (rd!=0) begin
                  registers[rd] = registers[rs1] >>> shamt;
                  result=registers[rd]; 
                  end
                  else
                        result=0;
                end
            end
            default: result = 0;
          endcase
        end
        7'b0000011: begin
          // Instructiuni load
           Jump=0;
          case (funct3)
            3'b000: begin  // LB
              registers[rd] = {{56{dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][7]}},dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][7:0]};
              result=registers[rd]; 
            end
            3'b001: begin  // LH
              registers[rd] = {{48{dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][15]}},dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][15:0]};
              result=registers[rd]; 
            end
            3'b010: begin  // LW
              registers[rd] = {{32{dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][31]}},dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][31:0]};
              result=registers[rd]; 
            end
            3'b011: begin  // LD
              registers[rd] = dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}];
              result=registers[rd]; 
            end
            3'b100: begin  // LBU
              registers[rd] = {56'b0,dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][7:0]};
              result=registers[rd]; 
            end
            3'b101: begin  // LHU
              registers[rd] = {48'b0,dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][15:0]}; 
              result=registers[rd]; 
            end
            3'b110: begin  // LWU
              registers[rd] = {32'b0,dataMemory[registers[rs1]+{{52{imm12[11]}},imm12}][31:0]};
              result=registers[rd]; 
            end
            default: result = 0;
          endcase
        end
        7'b0100011: begin
          // Instructiuni store
           Jump=0;
          case (funct3)
            3'b000: begin  // SB
              dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}] = registers[rs2][7:0];
              result = dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}];
            end
            3'b001: begin  // SH
              dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}] = registers[rs2][15:0];
              result = dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}];
            end
            3'b010: begin  // SW
              dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}] = registers[rs2][31:0];
              result = dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}];
            end
            3'b011: begin  // SD
              dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}] = registers[rs2];
              result = dataMemory[registers[rs1]+{{52{instruction[31]}},{instruction[31:25],instruction[11:7]}}];
            end
            default: result = 0;
          endcase
        end
        7'b0110111: begin  // LUI
        if (rd!=0) begin
          registers[rd] = {{32{instruction[31]}},instruction[31:12], 12'b0};
          result=registers[rd]; 
           Jump=0;
           end
           else
                        result=0;
        end
        7'b0010111: begin  // AUIPC
        if (rd!=0) begin
          registers[rd] = pc + {{32{instruction[31]}},instruction[31:12], 12'b0};
          regtest=instruction[31:12];
          result=registers[rd]; 
           Jump=0;
           end
           else
                        result=0;
        end
        7'b1101111: begin  // JAL
          registers[rd] = pc + 4;
          Jump = 1;
          jumpAddress=pc+{{43{instruction[31]}},{instruction[31],instruction[19:12],instruction[20],instruction[30:21]}, 1'b0};
          result=jumpAddress;
        end
        7'b1100111: begin  // JALR
          registers[rd] = pc + 4;
          Jump = 1;
          jumpAddress=registers[rs1]+{{52{imm12[11]}},imm12[11:1],1'b0};
          result=jumpAddress;
        end
        7'b1100011: begin
          // Instructiuni branch
          regtest={instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
          case (funct3)
            3'b000: begin  // BEQ
                  Jump=(registers[rs1] == registers[rs2]);
                  jumpAddress=pc+{{52{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
              result=Jump?jumpAddress:0;
            end
            3'b001: begin  // BNE
                  Jump=(registers[rs1] != registers[rs2]);
                  jumpAddress=pc+{{51{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                  result=Jump?jumpAddress:0;             	
            end
            3'b100: begin  // BLT
              regdif=registers[rs1] - registers[rs2];
                Jump=regdif[63];
jumpAddress=pc+{{51{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                result=Jump?jumpAddress:0;
            end
            3'b101: begin  // BGE
              regdif=registers[rs1] - registers[rs2];
                Jump=!regdif[63];
                jumpAddress=pc+{{51{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                result=Jump?jumpAddress:0;
            end
            3'b110: begin  // BLTU
                Jump=(registers[rs1] < registers[rs2]);
jumpAddress=pc+{{51{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                result=Jump?jumpAddress:0;
            end
            3'b111: begin  // BGEU
                Jump=(registers[rs1] >= registers[rs2]);
jumpAddress=pc+{{51{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                result=Jump?jumpAddress:0;
            end
            default: result = 0;
          endcase
        end
        default: result = 0;
      endcase
      if (Jump) begin
            pc = jumpAddress; // Actualizez PC in urma unui jump/branch
        end
    else begin
            pc= pc + 4; // Pentru celelalte instructiuni
        end
      end
    else
      //daca reset este activ,resetez pc, bancul de registre, flag-ul Jump si memoria de date
      begin
        pc = 64'h0;
        result=0;
        Jump = 0;
        for (i = 0; i <= 31; i = i + 1)
          registers[i] = (i==2)?128:0;
        $readmemh("data.mem", dataMemory);
    end
  
  end
endmodule