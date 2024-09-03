module ClockDivider (
  input wire clk_in,
  output reg clk_out
);
  reg [31:0] count;

  initial begin
    clk_out = 0; // Initializare cu valoarea 0
    count = 0; // Initializare cu valoarea 0
  end

  always @(posedge clk_in) begin
    if (count == 1) begin //50000000-1
      clk_out <= ~clk_out;
      count <= 0;
    end else begin
      count <= count + 1;
    end
  end
endmodule
module RISCVProcessor (
    input clk,
    input reset,
  output reg [15:0] result
);
  reg[63:0] pc;
  reg[63:0] regdif;
  reg Jump;
  reg[63:0] jumpAddress;
  reg [63:0] registers [0:31];
  reg [63:0] dataMemory[0:99];
  reg [8:0] memory[0:175];
  reg [31:0] instruction;
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg [6:0] funct7;
  reg [11:0] imm12;
  reg [4:0] shamt;
  reg [4:0] rs1;
  reg [4:0] rs2;
  reg [4:0] rd;
  integer i;
    initial begin
      //Citirea din fisier a continutului memoriei
      $readmemh("instructions.mem", memory);
      pc = 64'hFFFFFFFFFFFFFFFC; // Initializare cu -4
      //Initializare registrii de lucru
      Jump=0;
      jumpAddress=0;
      regdif=0;
      //Initializare cu 0 banc de registre
        for (i = 0; i <= 31; i = i + 1)
          registers[i] = 0;
      //Intializare cu 0 memorie de date
      $readmemh("data.mem", dataMemory);
      result=0;
    end
    wire clk_div;
  ClockDivider clk_divider (
    .clk_in(clk),
    .clk_out(clk_div)
  );
  //La fiecare schimbare a lui PC calculez noua instructiune si parametrii acesteia
  always @(pc) begin
        instruction = {memory[pc][7:0], memory[pc+1][7:0], memory[pc+2][7:0], memory[pc+3][7:0]};
        opcode = instruction[6:0];
      funct3 = instruction[14:12];
      funct7 = instruction[31:25];
      imm12 = instruction[31:20];
      shamt = instruction[24:20];
      rs1 = instruction[19:15];
      rs2 = instruction[24:20];
      rd = instruction[11:7];
    end
  always @(posedge clk_div) begin
        if (reset) begin
            pc = 64'hFFFFFFFFFFFFFFFC; // Initializare cu -4
        end
        else if (Jump) begin
            pc = jumpAddress; // Actualizez PC in urma unui jump/branch
        end
    else begin
            pc= pc + 4; // Pentru celelalte instructiuni
        end
    end
  //Prelucrarea instructiunii
  always @(negedge clk_div) begin
    if(!reset)
        // Identificarea tipului de instructiune
      case (opcode)
        7'b0110011: begin
           Jump=0;
          // Instructiuni de tip R
          case (funct3)
            3'b000: begin  // ADD, SUB
              if (funct7 == 7'b0000000)
                begin
                   registers[rd]= registers[rs1] + registers[rs2]; 
                   result=registers[rd]; 
                end
              else if (funct7 == 7'b0100000) 
              begin 
                registers[rd]= registers[rs1] - registers[rs2]; 
                result=registers[rd];          
              end 
            end
            3'b001: begin  // SLL
              registers[rd] = registers[rs1] << registers[rs2][4:0];
              result=registers[rd]; 
            end
            3'b010: begin  // SLT verificat pe cazul numerelor negative
              regdif=registers[rs1] - registers[rs2];
              registers[rd] = regdif[63];
              result=registers[rd]; 
            end
            3'b011: begin  // SLTU
              registers[rd] = (registers[rs1] < registers[rs2]) ? 1 : 0;
              result=registers[rd]; 
            end
            3'b100: begin  // XOR
              registers[rd] = registers[rs1] ^ registers[rs2];
              result=registers[rd]; 
            end
            3'b101: begin
              if (funct7 == 7'b0000000) begin  // SRL
                registers[rd] = registers[rs1] >> registers[rs2][4:0];
                result=registers[rd]; 
              end else if (funct7 == 7'b0100000) begin  // SRA
                registers[rd] = registers[rs1] >>> registers[rs2][4:0];
                result=registers[rd]; 
              end
            end
            3'b110: begin  // OR
              registers[rd] = registers[rs1] | registers[rs2];
              result=registers[rd]; 
            end
            3'b111: begin  // AND
              registers[rd] = registers[rs1] & registers[rs2];
              result=registers[rd]; 
            end
            default: result = 0;
          endcase
        end
        7'b0010011: begin
          // Instructiuni de tip I
           Jump=0;
          case (funct3)
            3'b000: begin  // ADDI
              registers[rd] = registers[rs1] + {{52{imm12[11]}},imm12};
              result=registers[rd]; 
            end
            3'b010: begin  // SLTI 
              regdif=registers[rs1]-{{52{imm12[11]}},imm12};
              registers[rd] = regdif[63];
              result=registers[rd]; 
            end
            3'b011: begin  // SLTIU
              registers[rd] = (registers[rs1] < {{52{imm12[11]}},imm12}) ? 1 : 0;
              result=registers[rd]; 
            end
            3'b100: begin  // XORI
              registers[rd] = registers[rs1] ^ {{52{imm12[11]}},imm12}; 
              result=registers[rd]; 
            end
            3'b110: begin  // ORI
              registers[rd] = registers[rs1] | {{52{imm12[11]}},imm12};
              result=registers[rd]; 
            end
            3'b111: begin  // ANDI
              registers[rd] = registers[rs1] & {{52{imm12[11]}},imm12};
              result=registers[rd]; 
            end
            3'b001: begin // SLLI
                registers[rd] = registers[rs1] << shamt;
                result=registers[rd]; 
            end
            3'b101: begin
              if (funct7 == 7'b0000000) 
                begin  // SRLI
                  registers[rd] = registers[rs1] >> shamt;
                  result=registers[rd]; 
                end 
              else if (funct7 == 7'b0100000) 
                begin  // SRAI
                  registers[rd] = registers[rs1] >>> shamt;
                  result=registers[rd]; 
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
          registers[rd] = {{32{instruction[31]}},instruction[31:12], 12'b0};
          result=registers[rd]; 
           Jump=0;
        end
        7'b0010111: begin  // AUIPC
          registers[rd] = pc + {{32{instruction[31]}},instruction[31:12], 12'b0};
          result=registers[rd]; 
           Jump=0;
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
          case (funct3)
            3'b000: begin  // BEQ
                  Jump=(registers[rs1] == registers[rs2]);
                  jumpAddress={{52{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
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
    else
      //daca reset este activ, resetez bancul de registre, flag-urile Jump si Branch si memoria de date
      begin
        result=0;
        Jump = 0;
        for (i = 0; i <= 31; i = i + 1)
          registers[i] = 0;
        $readmemh("data.mem", dataMemory);
    end
  
  end
endmodule