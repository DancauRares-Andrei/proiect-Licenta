import sys
import os
from PyQt5 import QtWidgets
from PyQt5.QtWidgets import QMessageBox, QFileDialog
from main_window_ui import Ui_Dialog
#Initializarea listelor de instructiuni si a numelor alternative pentru registri
loads = ["lb", "lh", "lw", "ld", "lbu", "lhu", "lwu"]
stores = ["sb", "sh", "sw", "sd"]
jumps = ["jal", "jalr"]
branches = ["beq", "bne", "blt", "bge", "bltu", "bgeu"]
others = ["lui", "auipc"]
registerAlternateName = {
    "zero": "x0",
    "ra": "x1",
    "sp": "x2",
    "gp": "x3",
    "tp": "x4",
    "t0": "x5",
    "t1": "x6",
    "t2": "x7",
    "s0": "x8",
    "fp": "x8",
    "s1": "x9",
    "a0": "x10",
    "a1": "x11",
    "a2": "x12",
    "a3": "x13",
    "a4": "x14",
    "a5": "x15",
    "a6": "x16",
    "a7": "x17",
    "s2": "x18",
    "s3": "x19",
    "s4": "x20",
    "s5": "x21",
    "s6": "x22",
    "s7": "x23",
    "s8": "x24",
    "s9": "x25",
    "s10": "x26",
    "s11": "x27",
    "t3": "x28",
    "t4": "x29",
    "t5": "x30",
    "t6": "x31",
}

#Functie care trunchiaza un numar la 32 de biti
def limit_32_bits(number):
    return number & 0xFFFFFFFF

#Clasa corespunzatoare ferestrei
class MainWindow(QtWidgets.QDialog):
    #Initializarea ferestrei cu functiile callback
    def __init__(self):
        super(MainWindow, self).__init__()
        self.ui = Ui_Dialog()
        self.ui.setupUi(self)
        self.ui.buttonDel.clicked.connect(self.buttonDel_clicked)
        self.ui.buttonSal.clicked.connect(self.buttonSal_clicked)
        self.ui.buttonIncFis.clicked.connect(self.buttonIncFis_clicked)
        self.ui.buttonCod.clicked.connect(self.buttonCod_clicked)
        self.ui.buttonInstr.clicked.connect(self.buttonInstr_clicked)
    #Functie care face validarea unui registru; va verifica daca registrul dat ca parametru este valid.
    def validare_registru(self, rd, nume_reg):
        if rd[0] != "x":
            try:
                rd = registerAlternateName[rd]
            except KeyError:
                QMessageBox.warning(self,"Avertisment",f"Nu am găsit echivalent pentru {nume_reg}! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                return 100
        rd = int(rd[1:])
        if rd > 32 or rd < 0:
            QMessageBox.warning(self,"Avertisment",f"Registru {nume_reg} in afara ariei de lucru! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
            return 100
        return rd
    #Functia de eliminare a continutului textBox-ului cu instructiuni din dreapta
    def buttonDel_clicked(self):
        self.ui.listInput.clear()
    #Functia de incarcare a unui fisier cu instructiuni in asamblare
    def buttonIncFis_clicked(self):
        file_path, _ = QFileDialog.getOpenFileName(self, "Citire fișier asamblare", "", "Assembly Files (*.s)")
        if file_path:
            with open(file_path, "r") as file:
                for line in file:
                    self.ui.textInstr.setText(line.strip())
                    self.buttonCod_clicked()
            QMessageBox.information(self, "Parcurgere completă", "Fișierul a fost parcurs!", QMessageBox.Ok)
    #Functia de salvare a instructiunilor din textBox in format explicativ
    def buttonSal_clicked(self):
        file_path, _ = QFileDialog.getSaveFileName(self, "Salvare în fișier input", "input_.txt", "Text Files (*.txt)")
        if file_path:
            with open(file_path, "w") as file:
                for index in range(self.ui.listInput.count()):
                    item = self.ui.listInput.item(index)
                    file.write(f"{item.text()}\n")
                QMessageBox.information(self,"Salvare completă","Instrucțiunile au fost salvate în format input!",QMessageBox.Ok,)
    #Functia de salvare a instructiunilor in format executabil pe procesor
    def buttonInstr_clicked(self):
        file_path, _ = QFileDialog.getSaveFileName(self,"Salvare în fișier instruction","instruction_.mem","Memory Files (*.mem)",)
        if file_path:
            with open(file_path, "w") as file:
                for index in range(self.ui.listInput.count()):
                    instruction = self.ui.listInput.item(index).text()
                    componente = instruction.split(" ")
                    rezultat = (componente[0][6:8]+ '\n' + componente[0][4:6] + '\n' + componente[0][2:4] + '\n' + componente[0][0:2] + '\n')
                    file.write(f"{rezultat}")
                QMessageBox.information(self,"Salvare completă","Instrucțiunile au fost salvate în format mem!",QMessageBox.Ok,)
    #Functia de codificare a unei instructiuni
    def buttonCod_clicked(self):
        try:
            #Impartirea instructiunii pe componente
            componente = self.ui.textInstr.toPlainText().split(" ")
            #In functie de numarul de componente si valoarea acestora, se formeaza instructiunea codificata in format hexazecimal
            #In cazul in care apar probleme pe parcursul parsarii instructiunii, utilizatorul va fi notificat printr-un MessageBox
            if len(componente) == 4:
                rd = componente[1].strip(",")
                rs1 = componente[2].strip(",")
                rd = self.validare_registru(rd, "rd")
                if rd == 100:
                    return
                rs1 = self.validare_registru(rs1, "rs1")
                if rs1 == 100:
                    return
                if componente[0][-1] == "i" or componente[0] == "sltiu":
                    imm = int(componente[3])
                    if imm > 2047 or imm < -2048:
                        QMessageBox.warning(self,"Avertisment",f"Valoare prea mică sau mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    if (imm > 63 or imm < 0) and (componente[0] == "slli" or componente[0] == "srli" or componente[0] == "srai"):
                        QMessageBox.warning(self,"Avertisment",f"Valoare prea mică sau mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    if componente[0] == "addi":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0
                    elif componente[0] == "slli":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0b001
                    elif componente[0] == "slti":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0b010
                    elif componente[0] == "xori":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0b100
                    elif componente[0] == "ori":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0b110
                    elif componente[0] == "andi":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0b111
                    elif componente[0] == "srli":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0b101
                    elif componente[0] == "srai":
                        opcode = 0b0010011
                        funct7 = 0b0100000
                        funct3 = 0b101
                    elif componente[0] == "sltiu":
                        opcode = 0b0010011
                        funct7 = 0
                        funct3 = 0b011
                    else:
                        QMessageBox.warning(self,"Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    instrCod = limit_32_bits(opcode | (rd << 7) | (funct3 << 12) | (rs1 << 15) | (imm << 20) | (funct7 << 25))
                    self.ui.listInput.addItem("{:08X}".format(instrCod) + "  " + self.ui.textInstr.toPlainText())
                elif componente[0] in branches:
                    opcode = 0b1100011
                    imm = int(componente[3])
                    if imm > 2047 or imm < -2048:
                        QMessageBox.warning(self,"Avertisment",f"Valoare prea mică sau mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    if componente[0] == "beq":
                        funct3 = 0b000
                    elif componente[0] == "bne":
                        funct3 = 0b001
                    elif componente[0] == "blt":
                        funct3 = 0b100
                    elif componente[0] == "bge":
                        funct3 = 0b101
                    elif componente[0] == "bltu":
                        funct3 = 0b110
                    elif componente[0] == "bgeu":
                        funct3 = 0b111
                    else:
                        QMessageBox.warning(self,"Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    instrCod = limit_32_bits(opcode | (funct3 << 12) | (rd << 15) | (rs1 << 20) | (((imm >> 12) & 1) << 31) | (((imm >> 5) & 0b111111) << 25) | (((imm >> 1) & 0b1111) << 8) | (((imm >> 11) & 1) << 7))
                    self.ui.listInput.addItem("{:08X}".format(instrCod) + "  " + self.ui.textInstr.toPlainText())
                else:
                    rs2 = componente[3].strip(",")
                    rs2 = self.validare_registru(rs2, "rs2")
                    if rs2 == 100:
                        return
                    opcode = 0b0110011
                    if componente[0] == "add":
                        funct3 = 0
                        funct7 = 0
                    elif componente[0] == "sub":
                        funct7 = 0b0100000
                        funct3 = 0
                    elif componente[0] == "sll":
                        funct7 = 0
                        funct3 = 0b001
                    elif componente[0] == "slt":
                        funct7 = 0
                        funct3 = 0b010
                    elif componente[0] == "sltu":
                        funct7 = 0
                        funct3 = 0b011
                    elif componente[0] == "xor":
                        funct7 = 0
                        funct3 = 0b100
                    elif componente[0] == "or":
                        funct7 = 0
                        funct3 = 0b110
                    elif componente[0] == "and":
                        funct7 = 0
                        funct3 = 0b111
                    elif componente[0] == "srl":
                        funct7 = 0
                        funct3 = 0b101
                    elif componente[0] == "sra":
                        funct7 = 0b0100000
                        funct3 = 0b101
                    else:
                        QMessageBox.warning(self,"Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    instrCod = limit_32_bits(opcode | (rd << 7) | (funct3 << 12) | (rs1 << 15) | (rs2 << 20) | (funct7 << 25))
                    self.ui.listInput.addItem("{:08X}".format(instrCod)+ "  " + self.ui.textInstr.toPlainText())
            elif len(componente) == 3:
                if componente[0] in others:
                    rd = componente[1].strip(",")
                    rd = self.validare_registru(rd, "rd")
                    if rd == 100:
                        return
                    imm = int(componente[2])
                    if imm > 1048575 or imm < -1048576:
                        QMessageBox.warning(self,"Avertisment",f"Valoare prea mică/mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return

                    if componente[0] == "lui":
                        opcode = 0b0110111
                    elif componente[0] == "auipc":
                        opcode = 0b0010111
                    else:
                        QMessageBox.warning(self,"Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    instrCod = limit_32_bits(opcode | (rd << 7) | (imm << 12))
                    self.ui.listInput.addItem("{:08X}".format(instrCod) + "  " + self.ui.textInstr.toPlainText())
                elif componente[0] in jumps:
                    if componente[0] == "jal":
                        opcode = 0b1101111
                        rd = componente[1].strip(",")
                        rd = self.validare_registru(rd, "rd")
                        if rd == 100:
                            return
                        imm = int(componente[2])
                        if imm > 1048575 or imm < -1048576:
                            QMessageBox.warning(self,"Avertisment",f"Valoare prea mică/mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                            return
                        instrCod = limit_32_bits(opcode | (rd << 7) | (((imm >> 20) & 1) << 31) | (((imm >> 1) & 0b1111111111) << 21) | (((imm >> 11) & 1) << 20) | (((imm >> 12) & 0b11111111) << 12))
                        self.ui.listInput.addItem("{:08X}".format(instrCod) + "  " + self.ui.textInstr.toPlainText())
                    elif componente[0] == "jalr":
                        opcode = 0b1100111
                        rd = componente[1].strip(",")
                        rd = self.validare_registru(rd, "rd")
                        if rd == 100:
                            return
                        offsetRs1 = componente[2].split("(")
                        rs1 = offsetRs1[1].strip(")")
                        rs1 = self.validare_registru(rs1, "rs1")
                        if rs1 == 100:
                            return
                        imm = int(offsetRs1[0])
                        if imm > 2047 or imm < -2048:
                            QMessageBox.warning(self,"Avertisment",f"Valoare prea mică/mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                            return
                        instrCod = limit_32_bits(opcode | (rd << 7) | (rs1 << 15) | (imm << 20))
                        self.ui.listInput.addItem("{:08X}".format(instrCod) + "  " + self.ui.textInstr.toPlainText())
                elif componente[0] in loads:
                    opcode = 0b0000011
                    rd = componente[1].strip(",")
                    rd = self.validare_registru(rd, "rd")
                    if rd == 100:
                        return
                    offsetRs1 = componente[2].split("(")
                    rs1 = offsetRs1[1].strip(")")
                    rs1 = self.validare_registru(rs1, "rs1")
                    if rs1 == 100:
                        return
                    imm = int(offsetRs1[0])
                    if imm > 2047 or imm < -2048:
                        QMessageBox.warning(self,"Avertisment",f"Valoare prea mică/mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    if componente[0] == "lb":
                        funct3 = 0
                    elif componente[0] == "lh":
                        funct3 = 0b001
                    elif componente[0] == "lw":
                        funct3 = 0b010
                    elif componente[0] == "ld":
                        funct3 = 0b011
                    elif componente[0] == "lbu":
                        funct3 = 0b100
                    elif componente[0] == "lhu":
                        funct3 = 0b101
                    elif componente[0] == "lwu":
                        funct3 = 0b110
                    else:
                        QMessageBox.warning(self,"Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    instrCod = limit_32_bits(opcode | (rd << 7) | (rs1 << 15) | (imm << 20) | (funct3 << 12))
                    self.ui.listInput.addItem("{:08X}".format(instrCod) + "  " + self.ui.textInstr.toPlainText())
                elif componente[0] in stores:
                    opcode = 0b0100011
                    rs2 = componente[1].strip(",")
                    rs2 = self.validare_registru(rs2, "rs2")
                    if rs2 == 100:
                        return
                    offsetRs1 = componente[2].split("(")
                    rs1 = offsetRs1[1].strip(")")
                    rs1 = self.validare_registru(rs1, "rs1")
                    if rs1 == 100:
                        return
                    imm = int(offsetRs1[0])
                    if imm > 2047 or imm < -2048:
                        QMessageBox.warning(self,"Avertisment",f"Valoare prea mică/mare pentru imm! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    if componente[0] == "sb":
                        funct3 = 0
                    elif componente[0] == "sh":
                        funct3 = 0b001
                    elif componente[0] == "sw":
                        funct3 = 0b010
                    elif componente[0] == "sd":
                        funct3 = 0b011
                    else:
                        QMessageBox.warning(self,"Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                        return
                    instrCod = limit_32_bits(opcode | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | ((imm & 0b11111) << 7) | (((imm >> 5) & 0b1111111) << 25))
                    self.ui.listInput.addItem("{:08X}".format(instrCod) + "  " + self.ui.textInstr.toPlainText())
                else:
                    QMessageBox.warning(self, "Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                    return
            else:
                QMessageBox.warning(self,"Avertisment",f"Operație nesuportată! {self.ui.textInstr.toPlainText()}",QMessageBox.Ok,)
                return
        except Exception as e:
            QMessageBox.warning(self,"Avertisment",f"A apărut o eroare la tratarea instrucțiunii:  {self.ui.textInstr.toPlainText()} {str(e)}",QMessageBox.Ok,)
            return

#Functia principala, in care se instantiaza clasa MainWindow.
def main():
    app = QtWidgets.QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()

