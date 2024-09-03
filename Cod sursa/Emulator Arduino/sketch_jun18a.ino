#include <Arduino.h>

// Functie de extindere a unui numar la un numar specificat de biti
int64_t sign_extend(int64_t number, int bits) {
    int64_t mask = (1LL << bits) - 1;
    int64_t sign_bit = number & (1LL << (bits - 1));

    if (sign_bit) {
        return number | (~mask & 0xFFFFFFFFFFFFFFFFLL);
    } else {
        return number;
    }
}

// Functie de trunchiere a unui numar la 64 de biti
uint64_t limit64bits(uint64_t number) {
    return number & 0xFFFFFFFFFFFFFFFFLL;
}

// Functie de trunchiere a unui numar la 16 de biti
uint16_t limit16bits(uint64_t number) {
    return number & 0xFFFF;
}
uint8_t valid_pins[16]={2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17};//5,6,7,8,9,10,11,12,13,14,15,16,19,20,21,22
// Functia de control a LED-urilor, in functie de rezultatul unei instructiuni
void set_pins_from_result(uint16_t result) {
    for (int i = 0; i < 16; ++i) {
        if (result & (1 << i)) {
            digitalWrite(valid_pins[i], HIGH);
        } else {
            digitalWrite(valid_pins[i], LOW);
        }
    }
}

class RISCVProcessor {
public:
    // Constructorul clasei, se initializeaza toate componentele procesorului si memoriile
    RISCVProcessor() {
        pc = 0;
        regdif = 0;
        Jump = false;
        jumpAddress = 0;
        for (int i = 0; i < 32; ++i) registers[i] = 0;
        //for (int i = 0; i < 100; ++i) dataMemory[i] = 0;
        //for (int i = 0; i < 176; ++i) memory[i] = 0;
        instruction = 0;
        opcode = 0;
        funct3 = 0;
        funct7 = 0;
        imm12 = 0;
        shamt = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        result = 0;
    }

    // Functia de preluare din memorie si de executare a unei instructiuni
    void execute() {
        /*if (pc == 0) {
            Serial.println();
        }*/
        // Preluarea instructiunii din ROM, in functie de valoarea registrului PC
        instruction = (memory[pc + 3] << 24) | (memory[pc + 2] << 16) | (memory[pc + 1] << 8) | (memory[pc]);
        // Decodificarea instructiunii in componente
        opcode = instruction & 0b1111111;
        funct3 = (instruction >> 12) & 0b111;
        funct7 = (instruction >> 25) & 0b1111111;
        imm12 = (instruction >> 20) & 0b111111111111;
        shamt = (instruction >> 20) & 0b11111;
        rs1 = (instruction >> 15) & 0b11111;
        rs2 = (instruction >> 20) & 0b11111;
        rd = (instruction >> 7) & 0b11111;

        // Executarea propriu-zisa a instructiunii, in functie de valorile decodificate
        if (opcode == 0b0110011) {  // Instructiuni de tip R
            if (funct3 == 0b000) {  // ADD, SUB
                if (funct7 == 0b0000000) { // ADD
                    registers[rd] = limit64bits(registers[rs1] + registers[rs2]);
                    result = limit16bits(registers[rd]);
                } else if (funct7 == 0b0100000) { // SUB
                    registers[rd] = limit64bits(registers[rs1] - registers[rs2]);
                    result = limit16bits(registers[rd]);
                }
            } else if (funct3 == 0b001) {  // SLL
                registers[rd] = limit64bits(registers[rs1] << (registers[rs2] & 0b11111));
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b010) {  // SLT
                regdif = limit64bits(registers[rs1] - registers[rs2]);
                registers[rd] = int(regdif >> 63);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b011) {  // SLTU
                registers[rd] = registers[rs1] < registers[rs2] ? 1 : 0;
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b100) {  // XOR
                registers[rd] = limit64bits(registers[rs1] ^ registers[rs2]);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b101) {
                if (funct7 == 0b0000000) {  // SRL
                    registers[rd] = limit64bits(registers[rs1] >> (registers[rs2] & 0b11111));
                    result = limit16bits(registers[rd]);
                } else if (funct7 == 0b0100000) {  // SRA
                    registers[rd] = limit64bits(registers[rs1] >> (registers[rs2] & 0b11111));
                    result = limit16bits(registers[rd]);
                }
            } else if (funct3 == 0b110) {  // OR
                registers[rd] = limit64bits(registers[rs1] | registers[rs2]);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b111) {  // AND
                registers[rd] = limit64bits(registers[rs1] & registers[rs2]);
                result = limit16bits(registers[rd]);
            } else {
                result = 0;
            }
        } else if (opcode == 0b0010011) {  // Instructiuni de tip I
            if (funct3 == 0b000) {  // ADDI
                registers[rd] = limit64bits(registers[rs1] + sign_extend(imm12, 12));
                result = limit16bits(registers[rd]);              
            } else if (funct3 == 0b001) {  // SLLI
                registers[rd] = limit64bits(registers[rs1] << shamt);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b010) {  // SLTI
                registers[rd] = (limit64bits(registers[rs1] - sign_extend(imm12, 12))) >> 63;
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b011) {  // SLTIU
                registers[rd] = registers[rs1] < sign_extend(imm12, 12);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b100) {  // XORI
                registers[rd] = limit64bits(registers[rs1] ^ sign_extend(imm12, 12));
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b110) {  // ORI
                registers[rd] = limit64bits(registers[rs1] | sign_extend(imm12, 12));
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b111) {  // ANDI
                registers[rd] = limit64bits(registers[rs1] & sign_extend(imm12, 12));
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b101) {
                if (funct7 == 0b0000000) { // SRLI
                    registers[rd] = limit64bits(registers[rs1] >> shamt);
                    result = limit16bits(registers[rd]);
                } else if (funct7 == 0b0100000) { // SRAI
                    registers[rd] = limit64bits(registers[rs1] >> shamt);
                    result = limit16bits(registers[rd]);
                }
            } else {
                result = 0;
            }
        } else if (opcode == 0b0000011) {  // Instructiuni Load
            if (funct3 == 0b000) {  // LB
                registers[rd] = sign_extend(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] & 0xff, 8);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b001) { // LH
                registers[rd] = sign_extend(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] & 0xFFFF, 16);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b010) { // LW
                registers[rd] = sign_extend(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] & 0xFFFFFFFF, 32);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b011) { // LD
                registers[rd] = sign_extend(limit64bits(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))]), 64);
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b100) { // LBU
                registers[rd] = dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] & 0xFF;
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b101) { // LHU
                registers[rd] = dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] & 0xFFFF;
                result = limit16bits(registers[rd]);
            } else if (funct3 == 0b110) { // LWU
                registers[rd] = dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] & 0xFFFFFFFF;
                result = limit16bits(registers[rd]);
            } else {
                result = 0;
            }
        } else if (opcode == 0b0100011) {  // Instructiuni Store; Pentru aceste instructiuni, imm12 se calculeaza intr-un mod diferit
            if (funct3 == 0b000) {  // SB
                imm12 = ((instruction >> 25) << 7) | ((instruction >> 7) & 0b11111);
                dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] = registers[rs2] & 0xff;
                result = limit16bits(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))]);
            } else if (funct3 == 0b001) { // SH
                imm12 = ((instruction >> 25) << 7) | ((instruction >> 7) & 0b11111);
                dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] = registers[rs2] & 0xFFFF;
                result = limit16bits(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))]);
            } else if (funct3 == 0b010) { // SW
                imm12 = ((instruction >> 25) << 7) | ((instruction >> 7) & 0b11111);
                dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] = registers[rs2] & 0xFFFFFFFF;
                result = limit16bits(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))]);
            } else if (funct3 == 0b011) { // SD
                imm12 = ((instruction >> 25) << 7) | ((instruction >> 7) & 0b11111);
                dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))] = registers[rs2];
                result = limit16bits(dataMemory[limit64bits(registers[rs1] + sign_extend(imm12, 12))]);

            } else {
                result = 0;
            }
        } else if (opcode == 0b0110111) {  // LUI
            imm12 = instruction >> 12;
            registers[rd] = limit64bits(sign_extend(imm12, 20) << 12);
            result = limit16bits(registers[rd]);

        } else if (opcode == 0b0010111) {  // AUIPC
            imm12 = instruction >> 12;
            registers[rd] = limit64bits(pc + (sign_extend(imm12, 20) << 12));
            result = limit16bits(registers[rd]);

        } else if (opcode == 0b1101111) {  // JAL
            registers[rd] = limit64bits(pc + 4);
            Jump = true;
            imm12 = (((instruction >> 31) << 19) | (((instruction >> 12) & 0xFF) << 11) | (instruction >> 21) & 0x3FF) << 1;
            jumpAddress = limit64bits(pc + sign_extend(imm12, 20));
            result = limit16bits(jumpAddress);

        } else if (opcode == 0b1100111) {  // JALR
            registers[rd] = pc + 4;
            Jump = true;
            jumpAddress = limit64bits(registers[rs1] + sign_extend(imm12 / 2 * 2, 12));
            result = limit16bits(jumpAddress);
            

        } else if (opcode == 0b1100011) { // Instructiuni branch; pentru aceste tipuri de instructiuni, imm12 se calculeaza intr-un mod diferit
            imm12 = ((instruction >> 31) << 12) | (((instruction >> 7) & 1) << 11) | (((instruction >> 25) & 0b111111) << 5) | ((instruction >> 8) & 0xf) << 1;
            if (funct3 == 0b000) { // BEQ
                Jump = (registers[rs1] == registers[rs2]);
                jumpAddress = limit64bits(pc + sign_extend(imm12, 12));
                result = limit16bits(jumpAddress ? Jump : 0);

            } else if (funct3 == 0b001) { // BNE
                Jump = (registers[rs1] != registers[rs2]);
                jumpAddress = limit64bits(pc + sign_extend(imm12, 12));
                result = limit16bits(jumpAddress ? Jump : 0);

            } else if (funct3 == 0b100) { // BLT
                Jump = (registers[rs1] - registers[rs2]) >> 63;
                jumpAddress = limit64bits(pc + sign_extend(imm12, 12));
                result = limit16bits(jumpAddress ? Jump : 0);

            } else if (funct3 == 0b101) { // BGE
                Jump = 1 - ((registers[rs1] - registers[rs2]) >> 63);
                jumpAddress = limit64bits(pc + sign_extend(imm12, 12));
                result = limit16bits(jumpAddress ? Jump : 0);

            } else if (funct3 == 0b110) { // BLTU
                Jump = (registers[rs1] < registers[rs2]);
                jumpAddress = limit64bits(pc + sign_extend(imm12, 12));
                result = limit16bits(jumpAddress ? Jump : 0);

            } else if (funct3 == 0b111) { // BGEU
                Jump = (registers[rs1] >= registers[rs2]);
                jumpAddress = limit64bits(pc + sign_extend(imm12, 12));
                result = limit16bits(jumpAddress ? Jump : 0);

            } else {
                result = 0;
            }
        } else {
            result = 0;
        }
        if (Jump) {
            pc = jumpAddress;
            Jump = false;
        } else {
            pc += 4;
        }
        Serial.println(result,HEX);
        set_pins_from_result(result);
    }

    // Functia de executare a programului din memoria ROM
    void run() {
        while (pc < sizeof(memory) / sizeof(memory[0])) {
            execute();
            delay(2000);
        }
    }

private:
    uint64_t pc;
    int64_t regdif;
    bool Jump;
    uint64_t jumpAddress;
    uint64_t registers[32];
    uint64_t dataMemory[10]={0};
    uint32_t memory[176]={0x93, 0x00, 0xA0, 0x00, 0x13, 0x81, 0x40, 0x01, 0xB3, 0x81, 0x20, 0x00, 0x33, 0x82, 0x21, 0x40, 0xB7, 0x12, 0x00, 0x00, 0x13, 0x03, 0x20, 0x03, 0xB3, 0xF3, 0x62, 0x00, 0x33, 0xEE, 0x53, 0x00, 0xB3, 0x4E, 0x7E, 0x00, 0x13, 0xFF, 0x3E, 0x00, 0x93, 0x6F, 0x6F, 0x00, 0x13, 0xC4, 0x9F, 0x00, 0x93, 0x54, 0x24, 0x00, 0x33, 0x99, 0x94, 0x00, 0xB3, 0x59, 0x99, 0x00, 0x93, 0x14, 0x24, 0x00, 0x23, 0x20, 0x30, 0x00, 0x03, 0x25, 0x00, 0x00, 0xB3, 0x22, 0x11, 0x00, 0x33, 0xB3, 0x91, 0x00, 0xB3, 0x53, 0x64, 0x40, 0x93, 0xA6, 0xD4, 0x02, 0x13, 0xB9, 0x49, 0x00, 0x93, 0x57, 0x25, 0x40, 0x23, 0x02, 0x30, 0x01, 0x23, 0x14, 0x80, 0x00, 0x23, 0x36, 0xC0, 0x01, 0x83, 0x0C, 0x40, 0x00, 0x83, 0x1B, 0x80, 0x00, 0x03, 0x4F, 0x40, 0x00, 0x83, 0x5B, 0x80, 0x00, 0x03, 0x65, 0x00, 0x00, 0x03, 0x3E, 0xC0, 0x00, 0xEF, 0x0B, 0x80, 0x00, 0x67, 0x8D, 0xC7, 0x08, 0x97, 0x44, 0x01, 0x00, 0x63, 0x02, 0x31, 0x06, 0x63, 0x92, 0xA4, 0x00, 0x63, 0xC4, 0xA4, 0x00, 0x63, 0xD2, 0xF1, 0x00, 0x63, 0xE5, 0xA4, 0x00, 0x63, 0xF2, 0xF1, 0x00, 0xE7, 0x00, 0x00, 0x00, 0x13, 0x00, 0x00, 0x00};
    uint32_t instruction;
    uint8_t opcode, funct3, funct7;
    uint16_t imm12, shamt, rs1, rs2, rd;
    uint16_t result;
};

// Instantierea clasei si executarea functiei run
RISCVProcessor processor;

void setup() {
    Serial.begin(9600);
    for (int i = 0; i < 16; ++i) {
        pinMode(valid_pins[i], OUTPUT);
    }
    processor.run();
}

void loop() {
}
