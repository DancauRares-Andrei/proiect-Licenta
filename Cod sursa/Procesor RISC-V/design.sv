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

module RISCVProcessor (
    input clk,
    input reset,
    input wire CLK_BUTT,
  output reg [15:0] result
);
  reg [1:0] bula;
  reg[63:0] pc,pc_jump;
  reg[63:0] reg_e,reg_m;
  reg[15:0] jumpAddress_e,jumpAddress_m;
  reg Jump;
  reg [63:0] registers [0:31];
  reg [8:0] dataMemory[0:128];
  reg [8:0] memory[0:175];
  reg [31:0] instruction_f, instruction_d, instruction_e,instruction_m,instruction_wb;
  reg [6:0] opcode_d,opcode_e,opcode_m,opcode_wb;
  reg [2:0] funct3_d,funct3_e,funct3_m,funct3_wb;
  reg [6:0] funct7_d,funct7_e,funct7_m,funct7_wb;
  reg [11:0] imm12_d,imm12_e,imm12_m;
  reg [5:0] shamt_d,shamt_e,shamt_m;//Pentru RV64I, shamt are 6 biti
  reg [4:0] rs1_d,rs1_e,rs1_m;
  reg [4:0] rs2_d,rs2_e,rs2_m;
  reg [4:0] rd_d,rd_e,rd_m,rd_wb;
  integer i;
    initial begin
      //Citirea din fisier a continutului memoriei
      $readmemh("instructions.mem", memory);
      pc = 0; // Initializare cu 0
      //Initializare cu 0 banc de registre
        for (i = 0; i <= 31; i = i + 1)
          registers[i] = (i==2)?128:0;
      //Intializare cu 0 memorie de date
      $readmemh("data.mem", dataMemory);
       //Initializare registrii de lucru
      Jump=0;
      result=0;
      bula=0;
      jumpAddress_e=0;
      jumpAddress_m=0;
      instruction_f=32'hAAAAAAFF;
      instruction_d=32'hFFFFFFFF;
      instruction_e=0;
      instruction_m=0;
      instruction_wb=0;
      opcode_d=0;
      funct3_d=0;
      funct7_d=0;
      imm12_d=0;
      shamt_d=0;
      rs1_d=0;
      rs2_d=0;
      rd_d=0;
      opcode_e=0;
      funct3_e=0;
      funct7_e=0;
      imm12_e=0;
      shamt_e=0;
      rs1_e=1;
      rs2_e=2;
      rd_e=3;
      opcode_m=0;
      funct3_m=0;
      funct7_m=0;
      imm12_m=0;
      shamt_m=0;
      rs1_m=4;
      rs2_m=5;
      rd_m=6;
      opcode_wb=0;
      funct3_wb=0;
      funct7_wb=0;
      rd_wb=0;
    end
    wire clk_div;
  //Instantiere modul de control al clock-ului
  ClockDivider clk_divider (
    .clk_in(clk),
    .clk_out(clk_div),
    .CLK_BUTT(CLK_BUTT)
  );
  always @(posedge clk_div) begin
    //Daca semnalul reset nu este activ, atunci continui operarea in pipeline.
    if(!reset) begin
      //Control al semnalului bula care se ocupă de gestiunea hazardurilor de date în pipeline.
      if(bula!=0 && Jump==0)
        bula<=bula-1;
      if (Jump==1) begin
            Jump<=0;
        pc<=pc_jump;
        end
      //Etapa fetch
    if(bula==0 && Jump==0)begin
    instruction_f <= {memory[pc+3][7:0], memory[pc+2][7:0], memory[pc+1][7:0], memory[pc][7:0]};
      pc<=pc+4;
    end
      //Etapa decode
    if(bula==0)begin
      if(Jump==0)begin
    instruction_d<=instruction_f;
    opcode_d <= instruction_f[6:0];
    funct3_d <= instruction_f[14:12];
    funct7_d <= instruction_f[31:25];
    imm12_d <= instruction_f[31:20];
    shamt_d <= instruction_f[25:20];
    rs1_d <= instruction_f[19:15];
    rs2_d <= instruction_f[24:20];
    rd_d <= instruction_f[11:7];
        //Tratare hazard date
        if(rs1_d == rd_e || rs2_d == rd_e)
      bula<=3'b010;
        else if(rs1_d == rd_m || rs2_d == rd_m)
      bula<=3'b001;
      end
    end
        //Etapa execute
    if(bula<1 && Jump==0) begin
    opcode_e <= opcode_d;
    funct3_e <= funct3_d;
    funct7_e <= funct7_d;
    imm12_e <= imm12_d;
    shamt_e <= shamt_d;
    rs1_e <= rs1_d;
    rs2_e <= rs2_d;
    rd_e <= rd_d;
    instruction_e<=instruction_d;
      //Stabilirea operatiei de executat in functie de parametrii decodificati.
      case (opcode_e)
        7'b0110011: begin
          // Instructiuni de tip R
          case (funct3_e)
            3'b000: begin  // ADD, SUB
              if (funct7_e == 7'b0000000)
                reg_e<= registers[rs1_e] + registers[rs2_e]; 
              else if(funct7_e ==  7'b0100000)
                reg_e<= registers[rs1_e] - registers[rs2_e];  
            end
            3'b001:  // SLL pentru RV64I
                reg_e <= registers[rs1_e] << registers[rs2_e][5:0];
            3'b010: begin  // SLT
              reg_e <= (registers[rs1_e] - registers[rs2_e])>>63;
            end
            3'b011: begin  // SLTU 
              reg_e <=  (registers[rs1_e] < registers[rs2_e]) ? 1 : 0;
            end
            3'b100:  // XOR
                reg_e<= registers[rs1_e] ^ registers[rs2_e];
            3'b101: begin
              if (funct7_e == 7'b0000000)  // SRL pentru RV64I
                  reg_e <= registers[rs1_e] >> registers[rs2_e][5:0];
 else if (funct7_e == 7'b0100000)  // SRA pentru RV64I
                  reg_e  <= registers[rs1_e] >>> registers[rs2_e][5:0];
            end
            3'b110:  // OR
                reg_e  <= registers[rs1_e] | registers[rs2_e];
            3'b111:  // AND
              reg_e <= registers[rs1_e] & registers[rs2_e];
          endcase
        end
        7'b0010011: begin
          // Instructiuni de tip I
          case (funct3_e)
            3'b000:  // ADDI
              reg_e  <= registers[rs1_e] + {{52{imm12_e[11]}},imm12_e};
            3'b010: begin  // SLTI 
              reg_e <= (registers[rs1_e]-{{52{imm12_e[11]}},imm12_e})>>63;
            end
            3'b011: begin  // SLTIU
              reg_e <=(registers[rs1_e] < {{52{imm12_e[11]}},imm12_e}) ? 1 : 0;
            end
            3'b100: begin  // XORI
              reg_e <=registers[rs1_e] ^ {{52{imm12_e[11]}},imm12_e}; 
            end
            3'b110: begin  // ORI
              reg_e <=registers[rs1_e] | {{52{imm12_e[11]}},imm12_e};
            end
            3'b111: begin  // ANDI
              reg_e <= registers[rs1_e] & {{52{imm12_e[11]}},imm12_e};
            end
            3'b001: begin // SLLI
              reg_e <= registers[rs1_e] << shamt_e;
            end
            3'b101: begin
              if (funct7_e == 7'b0000000) 
                begin  // SRLI
                  reg_e <= registers[rs1_e] >> shamt_e;
                end 
              else if (funct7_e == 7'b0100000) 
                begin  // SRAI
                  reg_e <= registers[rs1_e] >>> shamt_e;
                end
            end
          endcase
        end
        7'b0110111: begin  // LUI
          reg_e <= {{32{instruction_e[31]}},instruction_e[31:12], 12'b0};
        end
        7'b0010111: begin  // AUIPC
          reg_e <= pc - 12 + {{32{instruction_e[31]}},instruction_e[31:12], 12'b0};//Valoare PC de la fetch
        end
        7'b1101111: begin  // JAL 
          Jump <= 1;
          reg_e<= pc - 8;
          //In cadrul acestei instructiuni, se vor adauga instructiuni nop si se va continua cu etapa fetch a instructiunii 
          jumpAddress_e<=(pc-12)+{{43{instruction_e[31]}},{instruction_e[31],instruction_e[19:12],instruction_e[20],instruction_e[30:21]}, 1'b0};
          pc_jump<=(pc-12)+{{43{instruction_e[31]}},{instruction_e[31],instruction_e[19:12],instruction_e[20],instruction_e[30:21]}, 1'b0};
          //Initializare cu valori pentru a nu executa in mod eronat instructiuni.
          instruction_f<=32'hAAAAAAFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=3;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
        end
        7'b1100111: begin  // JALR
          //Aceasta instructiune functioneaza similar cu precedenta, dar modul de calcul al adresei de salt este diferit.
          reg_e<= pc - 8;
          Jump <= 1;
          jumpAddress_e<=registers[rs1_e]+{{52{imm12_e[11]}},imm12_e[11:1],1'b0};
          pc_jump<=registers[rs1_e]+{{52{imm12_e[11]}},imm12_e[11:1],1'b0};
           instruction_f<=32'hBBBBBBFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=31;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
        end
        7'b1100011: begin
          // Instructiuni branch
          case (funct3_e)
            //Pentru aceste instructiuni, daca saltul se face, se va proceda similar ca in cazul salturilor neconditionate.
            3'b000: begin  // BEQ
              if(registers[rs1_e] == registers[rs2_e]) begin
                Jump<=1;
                reg_e<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                pc_jump<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                 instruction_f<=32'hAAAAAAFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=3;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
              end
              else
                reg_e<=0;
            end
            3'b001: begin  // BNE
              if(registers[rs1_e] != registers[rs2_e]) begin
                Jump<=1;
                reg_e<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                pc_jump<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                 instruction_f<=32'hAAAAAAFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=3;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
              end
              else
                reg_e<=0;
            end
            3'b100: begin  // BLT
              if((registers[rs1_e] - registers[rs2_e])>>63) begin
                Jump<=1;
                reg_e<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                pc_jump<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                 instruction_f<=32'hAAAAAAFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=3;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
              end
              else
                reg_e<=0;
            end
            3'b101: begin  // BGE
              if(!((registers[rs1_e] - registers[rs2_e])>>63)) begin
                Jump<=1;
                reg_e<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                pc_jump<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                 instruction_f<=32'hAAAAAAFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=3;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
              end
              else
                reg_e<=0;
            end
            3'b110: begin  // BLTU
              if(registers[rs1_e] < registers[rs2_e]) begin
                Jump<=1;
                reg_e<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                pc_jump<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                 instruction_f<=32'hAAAAAAFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=3;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
              end
              else
                reg_e<=0;
            end
            3'b111: begin  // BGEU
              if(registers[rs1_e] >= registers[rs2_e]) begin
               Jump<=1;
                reg_e<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
                pc_jump<=pc-12+{{52{instruction_e[31]}},instruction_e[31],instruction_e[7],instruction_e[30:25],instruction_e[11:8],1'b0};
          instruction_f<=32'hAAAAAAFF;
      instruction_d<=32'hFFFFFFFF;
          opcode_d<=0;
          rd_d<=0;
          funct3_d<=0;
          rs1_d<=0;
          rs2_d<=0;
          funct7_d<=0;
          shamt_d<=0;
          imm12_d<=0;
          instruction_e<=0;
          opcode_e<=0;
          rd_e<=3;
          funct3_e<=0;
          rs1_e<=1;
          rs2_e<=2;
          funct7_e<=0;
          shamt_e<=0;
          imm12_e<=0;
              end
              else
                reg_e<=0;
            end
          endcase
        end
      endcase
      end
      //Etapa memory
      jumpAddress_m<=jumpAddress_e;
      if(bula!=1) begin
       opcode_m <= opcode_e;
    funct3_m <= funct3_e;
    funct7_m <= funct7_e;
    imm12_m <= imm12_e;
    shamt_m <= shamt_e;
    rs1_m <= rs1_e;
    rs2_m <= rs2_e;
    rd_m <= rd_e;
    instruction_m<=instruction_e;
        //Pentru aceasta etapa, au impact instructiunile de load si store in memorie.
      case (opcode_m)
        7'b0000011: begin
          // Instructiuni load
          case (funct3_m)
            3'b000: begin  // LB
              reg_m <= {{56{dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7]}},dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0]};
            end
            3'b001: begin  // LH
              reg_m <= {{48{dataMemory[1+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7]}},dataMemory[1+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0]};
            end
            3'b010: begin  // LW
              reg_m <= {{32{dataMemory[3+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7]}},dataMemory[3+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[2+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[1+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0]};
            end
            3'b011: begin  // LD
              reg_m<= {dataMemory[7+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[6+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[5+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[4+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[3+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[2+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[1+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0]}; 
            end
            3'b100: begin  // LBU
              reg_m <= {56'b0,dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0]};
            end
            3'b101: begin  // LHU
              reg_m <= {48'b0,dataMemory[1+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0]}; 
            end
            3'b110: begin  // LWU
              reg_m <= {32'b0,dataMemory[3+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[2+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[1+registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0],dataMemory[registers[rs1_m]+{{52{imm12_m[11]}},imm12_m}][7:0]};
            end
          endcase
        end
        7'b0100011: begin
          // Instructiuni store
          case (funct3_m)
            3'b000: begin  // SB
              dataMemory[registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}] <= registers[rs2_m][7:0];
              reg_m<=registers[rs2_m][7:0];
            end
            3'b001: begin  // SH
              {dataMemory[1+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0]} <= registers[rs2_m][15:0];
              reg_m<=registers[rs2_m][7:0];
            end
            3'b010: begin  // SW
              {dataMemory[3+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[2+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[1+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0]}  <= registers[rs2_m][31:0];
              reg_m<= registers[rs2_m][31:0];
            end
            3'b011: begin  // SD
              {dataMemory[7+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[6+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[5+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[4+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[3+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[2+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[1+registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0],dataMemory[registers[rs1_m]+{{52{instruction_m[31]}},{instruction_m[31:25],instruction_m[11:7]}}][7:0]} = registers[rs2_m];
              reg_m<=registers[rs2_m];
            end
            default: reg_m<=0;
          endcase
        end
        default:  reg_m<=reg_e;
      endcase
      end
      //Etapa write back
        opcode_wb<=opcode_m;
    funct3_wb <= funct3_m;
    funct7_wb <= funct7_m;
    rd_wb <= rd_m;
    instruction_wb<=instruction_m;
      //Este etapa in care se scrie rezultatul operatiei in result si in registrul destinatie.
      case (opcode_wb)
        7'b0110011: begin
          // Instructiuni de tip R
          case (funct3_wb)
            3'b000: begin  // ADD, SUB
              if (funct7_wb == 7'b0000000)
                begin
                  if (rd_wb!=0) begin
                    registers[rd_wb]<= reg_m; 
                    result<=reg_m; 
                  end
                  else
                        result<=0;
                end
              else if (funct7_wb == 7'b0100000) 
              begin 
                if (rd_wb!=0) begin
                  registers[rd_wb]<= reg_m; 
                  result<=reg_m;      
                end  
                else
                        result<=0;  
              end 
            end
            3'b001: begin  // SLL pentru RV64I
              if (rd_wb!=0) begin
                registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b010: begin  // SLT
              if (rd_wb!=0) begin
                registers[rd_wb] <= reg_m;
              result<= reg_m; 
              end
              else
                        result<=0;
            end
            3'b011: begin  // SLTU 
              if (rd_wb!=0) begin
                registers[rd_wb] <= reg_m;
              result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b100: begin  // XOR
              if (rd_wb!=0) begin
                registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b101: begin
              if (funct7_wb == 7'b0000000) begin  // SRL pentru RV64I
                if (rd_wb!=0) begin
                  registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
                end
                else
                        result<=0;
              end else if (funct7_wb == 7'b0100000) begin  // SRA pentru RV64I
                if (rd_wb!=0) begin
                  registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
                end
                else
                        result<=0;
              end
            end
            3'b110: begin  // OR
              if (rd_wb!=0) begin
                registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b111: begin  // AND
              if (rd_wb!=0) begin
              registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end
              else
                        result<=0; 
            end
            default: result <= 0;
          endcase
        end
        7'b0010011: begin
          // Instructiuni de tip I
          case (funct3_wb)
            3'b000: begin  // ADDI
              if (rd_wb!=0) begin
              registers[rd_wb] <= reg_m;
                result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b010: begin  // SLTI 
              if (rd_wb!=0) begin
              registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b011: begin  // SLTIU
              if (rd_wb!=0) begin
              registers[rd_wb]<= reg_m; 
              result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b100: begin  // XORI
              if (rd_wb!=0) begin
              registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b110: begin  // ORI
              if (rd_wb!=0) begin
              registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end
              else
                        result<=0;
            end
            3'b111: begin  // ANDI
              if (rd_wb!=0) begin
              registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
              end 
              else
                        result<=0;
            end
            3'b001: begin // SLLI
              if (rd_wb!=0) begin
                registers[rd_wb]<= reg_m; 
                  result<=reg_m;  
                end
                else
                        result<=0;
            end
            3'b101: begin
              if (funct7_wb == 7'b0000000) 
                begin  // SRLI
                  if (rd_wb!=0) begin
                  registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
                  end
                  else
                        result<=0;
                end 
              else if (funct7_wb == 7'b0100000) 
                begin  // SRAI
                  if (rd_wb!=0) begin
                  registers[rd_wb]<= reg_m; 
                  result<=reg_m; 
                  end
                  else
                        result<=0;
                end
            end
            default: result <= 0;
          endcase
        end
        7'b0000011: begin//Load-uri
          case (funct3_m)
            3'b000: begin  // LB
              registers[rd_m] <= reg_m;
              result <= reg_m;
            end
            3'b001: begin  // LH
              registers[rd_m] <= reg_m;
              result <= reg_m;
            end
            3'b010: begin  // LW
              registers[rd_m] <= reg_m;
              result <= reg_m;
            end
            3'b011: begin  // LD
              registers[rd_m] <= reg_m;
              result <= reg_m;
            end
            3'b100: begin  // LBU
              registers[rd_m] <= reg_m;
              result <= reg_m;
            end
            3'b101: begin  // LHU
              registers[rd_m] <= reg_m;
              result <= reg_m;
            end
            3'b110: begin  // LWU
              registers[rd_m] <= reg_m;
              result <= reg_m;
            end
          endcase
        end
        7'b0100011: begin//Store-uri
          result<=reg_m;
        end
        7'b0110111: begin  // LUI
          if (rd_wb!=0) begin
          registers[rd_wb]<= reg_m; 
          result<=reg_m; 
           end
           else
                        result<=0;
        end
        7'b0010111: begin  // AUIPC
          if (rd_wb!=0) begin
          registers[rd_wb]<= reg_m; 
          result<=reg_m; 
           end
           else
                        result<=0;
        end
        7'b1101111: begin  // JAL
          registers[rd_wb]<= reg_m; 
          result<=jumpAddress_m; 
        end
        7'b1100111: begin  // JALR
          registers[rd_wb]<= reg_m;
          result<=jumpAddress_m;
        end
        7'b1100011: begin
          // Instructiuni branch
          case (funct3_wb)
            3'b000: begin  // BEQ
              result<=reg_m;
            end
            3'b001: begin  // BNE
                 result<=reg_m;            	
            end
            3'b100: begin  // BLT
              result<=reg_m;
            end
            3'b101: begin  // BGE
              result<=reg_m;
            end
            3'b110: begin  // BLTU
                result<=reg_m;
            end
            3'b111: begin  // BGEU
                result<=reg_m;
            end
            default: result <= 0;
          endcase
        end
        default: result<= 0;
      endcase
      end
    else
      //Daca reset este activ,resetez pc, bancul de registre, flag-ul Jump si memoria de date.
      begin
        pc <= 64'h0;
        result<=0;
        Jump <= 0;
        jumpAddress_e<=0;
      jumpAddress_m<=0;
        bula<=0;
        for (i = 0; i <= 31; i = i + 1)
          registers[i] <= (i==2)?128:0;
        $readmemh("data.mem", dataMemory);
        instruction_f=32'hAAAAAAFF;
      instruction_d=32'hFFFFFFFF;
      instruction_e<=0;
      instruction_m<=0;
      instruction_wb<=0;
      opcode_d<=0;
      funct3_d<=0;
      funct7_d<=0;
      imm12_d<=0;
      shamt_d<=0;
      rs1_d<=0;
      rs2_d<=0;
      rd_d<=0;
      opcode_e<=0;
      funct3_e<=0;
      funct7_e<=0;
      imm12_e<=0;
      shamt_e<=0;
      rs1_e<=0;
      rs2_e<=0;
      rd_e<=0;
      opcode_m<=0;
      funct3_m<=0;
      funct7_m<=0;
      imm12_m<=0;
      shamt_m<=0;
      rs1_m<=0;
      rs2_m<=0;
      rd_m<=0;
      opcode_wb<=0;
      funct3_wb<=0;
      funct7_wb<=0;
      rd_wb<=0;
    end
  
  end
endmodule