module processor (
    input wire clk,
    input wire reset,
    input wire [31:0] instruction,
    output reg [63:0] result
);
  reg [6:0] opcode;
  reg [4:0] funct3;
  reg [6:0] funct7;
  reg [11:0] imm12;
  reg [11:0] imm20;
  reg [6:0] shamt;
  reg [4:0] rs1;
  reg [4:0] rs2;
  reg [4:0] rd;
  reg [63:0] pc;
  reg [63:0] regfile[0:31];
  reg [63:0] memory[0:63];
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc <= 64'h0;
      for (int i = 0; i < 32; i = i + 1) begin
        regfile[i] <= 64'h0;
      end
      for (int i = 0; i < 64; i = i + 1) begin
        memory[i] <= 64'h0;
      end
    end else begin
      pc <= pc + 4;
      opcode <= instruction[6:0];
      funct3 <= instruction[14:12];
      funct7 <= instruction[31:25];
      imm12 <= instruction[31:20];
      imm20 <= instruction[31:12];
      shamt <= instruction[24:20];
      rs1 <= instruction[19:15];
      rs2 <= instruction[24:20];
      rd <= instruction[11:7];
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      result <= 64'h0;
    end else begin
      case (opcode)
        7'b0110011: begin
          // R-type instructions
          case (funct3)
            3'b000: begin  // ADD, SUB
              if (funct7 == 7'b0000000) result <= regfile[rs1] + regfile[rs2];
              else if (funct7 == 7'b0100000) result <= regfile[rs1] - regfile[rs2];
              regfile[rd] <= result;
            end
            3'b001: begin  // SLL
              result <= regfile[rs1] << (regfile[rs2] & 5'b11111);
              regfile[rd] <= result;
            end
            3'b010: begin  // SLT
              result <= (regfile[rs1] < regfile[rs2]) ? 1 : 0;
              regfile[rd] <= result;
            end
            3'b011: begin  // SLTU
              result <= (regfile[rs1] < regfile[rs2]) ? 1 : 0;
              regfile[rd] <= result;
            end
            3'b100: begin  // XOR
              result <= regfile[rs1] ^ regfile[rs2];
              regfile[rd] <= result;
            end
            3'b101: begin
              if (funct7 == 7'b0000000) begin  // SRL
                result <= regfile[rs1] >> (regfile[rs2] & 5'b11111);
                regfile[rd] <= result;
              end else if (funct7 == 7'b0100000) begin  // SRA
                result <= $signed(regfile[rs1]) >>> (regfile[rs2] & 5'b11111);
                regfile[rd] <= result;
              end
            end
            3'b110: begin  // OR
              result <= regfile[rs1] | regfile[rs2];
              regfile[rd] <= result;
            end
            3'b111: begin  // AND
              result <= regfile[rs1] & regfile[rs2];
              regfile[rd] <= result;
            end
            default: result <= 64'h0;
          endcase
        end
        7'b0010011: begin
          // I-type instructions
          case (funct3)
            3'b000: begin  // ADDI
              result <= regfile[rs1] + imm12;
              regfile[rd] <= result;
            end
            3'b010: begin  // SLTI
              result <= (regfile[rs1] < imm12) ? 1 : 0;
              regfile[rd] <= result;
            end
            3'b011: begin  // SLTIU
              result <= (regfile[rs1] < imm12) ? 1 : 0;
              regfile[rd] <= result;
            end
            3'b100: begin  // XORI
              result <= regfile[rs1] ^ imm12;
              regfile[rd] <= result;
            end
            3'b110: begin  // ORI
              result <= regfile[rs1] | imm12;
              regfile[rd] <= result;
            end
            3'b111: begin  // ANDI
              result <= regfile[rs1] & imm12;
              regfile[rd] <= result;
            end
            3'b001: begin
              if (funct7 == 7'b0000000) begin  // SLLI
                result <= regfile[rs1] << shamt;
                regfile[rd] <= result;
              end
            end
            3'b101: begin
              if (funct7 == 7'b0000000) begin  // SRLI
                result <= regfile[rs1] >> shamt;
                regfile[rd] <= result;
              end else if (funct7 == 7'b0100000) begin  // SRAI
                result <= $signed(regfile[rs1]) >>> shamt;
                regfile[rd] <= result;
              end
            end
            default: result <= 64'h0;
          endcase
        end
        7'b0000011: begin
          // Load instructions
          case (funct3)
            3'b000: begin  // LB
              result <= memory[regfile[rs1]+imm12];
              regfile[rd] <= result;
            end
            3'b001: begin  // LH
              result <= memory[regfile[rs1]+imm12];
              regfile[rd] <= result;
            end
            3'b010: begin  // LW
              result <= memory[regfile[rs1]+imm12];
              regfile[rd] <= result;
            end
            3'b011: begin  // LD
              result <= memory[regfile[rs1]+imm12];
              regfile[rd] <= result;
            end
            3'b100: begin  // LBU
              result <= memory[regfile[rs1]+imm12];
              regfile[rd] <= result;
            end
            3'b101: begin  // LHU
              result <= memory[regfile[rs1]+imm12];
              regfile[rd] <= result;
            end
            3'b110: begin  // LWU
              result <= memory[regfile[rs1]+imm12];
              regfile[rd] <= result;
            end
            default: result <= 64'h0;
          endcase
        end
        7'b0100011: begin
          // Store instructions
          // imm12<={instruction[31:25],instruction[11:7]};
          case (funct3)
            3'b000: begin  // SB
              memory[regfile[rs1]+{instruction[31:25], instruction[11:7]}] <= regfile[rs2][7:0];
              result <= regfile[rs2][7:0];
            end
            3'b001: begin  // SH
              memory[regfile[rs1]+{instruction[31:25], instruction[11:7]}] <= regfile[rs2][15:0];
              result <= regfile[rs2][7:0];
            end
            3'b010: begin  // SW
              memory[regfile[rs1]+{instruction[31:25], instruction[11:7]}] <= regfile[rs2][31:0];
              result <= regfile[rs2][7:0];
            end
            3'b011: begin  // SD
              memory[regfile[rs1]+{instruction[31:25], instruction[11:7]}] <= regfile[rs2][63:0];
              result <= regfile[rs2][63:0];
            end
            default: result <= 64'h0;
          endcase
        end
        7'b0110111: begin  // LUI
          result <= {imm20, 12'b0};
          regfile[rd] <= result;
        end
        7'b1101111: begin  // JAL
          result <= pc + 4;
          pc <= pc + imm20;
          regfile[rd] <= result;
        end
        7'b1100111: begin  // JALR
          result <= pc + 4;
          pc <= (regfile[rs1] + imm12) & 32'hfffffffe;
          regfile[rd] <= result;
        end
        7'b0010111: begin  // AUIPC
          result <= pc + {imm20, 12'b0};
          regfile[rd] <= result;
        end
        7'b1100011: begin
          // Branch instructions
          // imm12<={instruction[31:25],instruction[11:7]};
          case (funct3)
            3'b000: begin  // BEQ
              if (regfile[rs1] == regfile[rs2]) pc <= pc + {instruction[31:25], instruction[11:7]};
            end
            3'b001: begin  // BNE
              if (regfile[rs1] != regfile[rs2]) pc <= pc + {instruction[31:25], instruction[11:7]};
            end
            3'b100: begin  // BLT
              if (regfile[rs1] < regfile[rs2]) pc <= pc + {instruction[31:25], instruction[11:7]};
            end
            3'b101: begin  // BGE
              if (regfile[rs1] >= regfile[rs2]) pc <= pc + {instruction[31:25], instruction[11:7]};
            end
            3'b110: begin  // BLTU
              if (regfile[rs1] < regfile[rs2]) pc <= pc + {instruction[31:25], instruction[11:7]};
            end
            3'b111: begin  // BGEU
              if (regfile[rs1] >= regfile[rs2]) pc <= pc + {instruction[31:25], instruction[11:7]};
            end
            default: result <= 64'h0;
          endcase
        end
        default: result <= 64'h0;
      endcase
    end
  end
endmodule
