using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace Codificator_RISC_V
{
    public partial class CodificatorRISCV : Form
    {
        private List<string> _loads, _stores, _jumps, _branches, _others;
        private Dictionary<string, string> _registerAlternateName;
        /// <summary>
        /// Functia apelata la apasarea butonului de salvare in fisier instructiune.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void buttonInstr_Click(object sender, EventArgs e)
        {
            saveFileDialog.Filter = "Memory File (*.mem)|*.mem|All Files (*.*)|*.*";
            saveFileDialog.FilterIndex = 1;
            saveFileDialog.FileName = "instruction_.mem";
            string continutInput = textBoxInput.Text;
            if (continutInput.Length == 0)
            {
                MessageBox.Show("Nu pot salva un fișier dacă nu au fost procesate instrucțiuni!");
                return;
            }
            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                string caleFisier = saveFileDialog.FileName;

                try
                {               
                    string rezultat = "";
                    //Se extrag octetii din instructiune in ordine inversa si se afiseaza câte un octet pe linie,
                    //pentru a putea fi cititi de functia readmemh din Verilog.
                    List<string> instructions = continutInput.Split('\r').Select(x => x.Replace("\n", "")).Where(s => !string.IsNullOrEmpty(s)).ToList();
                    foreach (string instruction in instructions)
                    {
                        string[] componente = instruction.Split(' ');
                        rezultat += string.Join(Environment.NewLine, componente[0].Substring(6, 2), componente[0].Substring(4, 2), componente[0].Substring(2, 2), componente[0].Substring(0, 2), "");
                    }
                    rezultat = rezultat.Substring(0, rezultat.Length - 2);
                    File.WriteAllText(caleFisier, rezultat);

                    MessageBox.Show("Instrucțiunile au fost salvate în format mem!");
                }
                catch (Exception ex)
                {
                    MessageBox.Show("A apărut o eroare la salvarea fișierului: " + ex.Message);
                }
            }
        }
        /// <summary>
        /// Functia apelata la apasarea butonului de incarcare a unor instructiuni din fisier.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void buttonIncFis_Click(object sender, EventArgs e)
        {
            //Se deschide fisierul si se apeleaza functia de codificare pentru fiecare instructiune
            openFileDialog.Filter = "Assembly Files (*.s)|*.s";

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                string caleFisier = openFileDialog.FileName;

                try
                {
                    using (StreamReader reader = new StreamReader(caleFisier))
                    {
                        while (!reader.EndOfStream)
                        {
                            string linie = reader.ReadLine();
                            textBoxInstr.Text = linie.Trim(' ').Replace("\r\n", "");
                            this.buttonCod_Click(sender, e);
                        }
                    }

                    MessageBox.Show("Fișier încărcat și interpretat cu succes!");
                }
                catch (Exception ex)
                {
                    MessageBox.Show("A apărut o eroare la citirea și interpretarea fișierului: " + ex.Message);
                }
            }
        }
        /// <summary>
        /// Functia apelata la apasarea butonului de eliminare a instructiunilor din dreapta.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void buttonDel_Click(object sender, EventArgs e)
        {
            //Se elimina continutul textBox-ului aferent
            textBoxInput.Text = "";
        }

        /// <summary>
        /// Functia apelata la apasarea butonului de salvare in fisier input, folosit la
        /// explicarea codificarii instructiunii.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void buttonSal_Click(object sender, EventArgs e)
        {
            saveFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*";
            saveFileDialog.FilterIndex = 1;
            saveFileDialog.FileName = "input_.txt";
            if (textBoxInput.Text.Length == 0)
            {
                MessageBox.Show("Nu pot salva un fișier dacă nu au fost procesate instrucțiuni!");
                return;
            }
            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                string caleFisier = saveFileDialog.FileName;

                try
                {
                    //Instructiunile afisate in textBox corespund cu formatul
                    //in care vreau sa afisez instructiunile in fisier. 
                    File.WriteAllText(caleFisier, textBoxInput.Text.Substring(0, textBoxInput.Text.Length - 2));

                    MessageBox.Show("Instrucțiunile au fost salvate în format input!");
                }
                catch (Exception ex)
                {
                    MessageBox.Show("A apărut o eroare la salvarea fișierului: " + ex.Message);
                }
            }
        }

        
        /// <summary>
        /// Functia de initializare a codificatorului, se initializeaza listele de instructiuni si dictionarul de nume alternative pentru registri
        /// </summary>
        public CodificatorRISCV()
        {
            InitializeComponent();
            //Imi initializez listele de instructiuni si numele alternative pentru registri.
            _loads = new List<string> { "lb", "lh", "lw", "ld", "lbu", "lhu", "lwu" };
            _stores = new List<string> { "sb", "sh", "sw", "sd" };
            _jumps = new List<string> { "jal", "jalr" };
            _branches = new List<string> { "beq", "bne", "blt", "bge", "bltu", "bgeu" };
            _others = new List<string> { "lui", "auipc" };
            _registerAlternateName = new Dictionary<string, string>();
            _registerAlternateName.Add("zero", "x0");
            _registerAlternateName.Add("ra", "x1");
            _registerAlternateName.Add("sp", "x2");
            _registerAlternateName.Add("gp", "x3");
            _registerAlternateName.Add("tp", "x4");
            _registerAlternateName.Add("t0", "x5");
            _registerAlternateName.Add("t1", "x6");
            _registerAlternateName.Add("t2", "x7");
            _registerAlternateName.Add("s0", "x8");
            _registerAlternateName.Add("fp", "x8");
            _registerAlternateName.Add("s1", "x9");
            _registerAlternateName.Add("a0", "x10");
            _registerAlternateName.Add("a1", "x11");
            _registerAlternateName.Add("a2", "x12");
            _registerAlternateName.Add("a3", "x13");
            _registerAlternateName.Add("a4", "x14");
            _registerAlternateName.Add("a5", "x15");
            _registerAlternateName.Add("a6", "x16");
            _registerAlternateName.Add("a7", "x17");
            _registerAlternateName.Add("s2", "x18");
            _registerAlternateName.Add("s3", "x19");
            _registerAlternateName.Add("s4", "x20");
            _registerAlternateName.Add("s5", "x21");
            _registerAlternateName.Add("s6", "x22");
            _registerAlternateName.Add("s7", "x23");
            _registerAlternateName.Add("s8", "x24");
            _registerAlternateName.Add("s9", "x25");
            _registerAlternateName.Add("s10", "x26");
            _registerAlternateName.Add("s11", "x27");
            _registerAlternateName.Add("t3", "x28");
            _registerAlternateName.Add("t4", "x29");
            _registerAlternateName.Add("t5", "x30");
            _registerAlternateName.Add("t6", "x31");
        }
        /// <summary>
        /// Functie apelata la apasarea butonului de codificare a instructiunii.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void buttonCod_Click(object sender, EventArgs e)
        {
            try
            {
                //Citirea instructiunii
                string instructiune = textBoxInstr.Text;
                //Impartirea instructiunii pe componente
                string[] componente = instructiune.Split(' ');
                //In functie de numarul de componente si de valoarea acestora, se va calcula codificarea hexazecimala a instructiunii.
                //Daca apar erori in parsarea instructiunii, utilizatorul va fi notificat printr-un MessageBox.
                if (componente.Length == 4)
                {
                    string rd = componente[1].Replace(",", "");
                    string rs1 = componente[2].Replace(",", "");
                    if (!rd.StartsWith("x"))
                    {
                        _registerAlternateName.TryGetValue(rd, out rd);
                        if (rd == null)
                        {
                            MessageBox.Show($"Nu am găsit echivalent pentru rd! {instructiune}");
                            return;
                        }
                    }
                    if (!rs1.StartsWith("x"))
                    {
                        _registerAlternateName.TryGetValue(rs1, out rs1);
                        if (rs1 == null)
                        {
                            MessageBox.Show($"Nu am găsit echivalent pentru rs1! {instructiune}");
                            return;
                        }
                    }
                    int rdInt = int.Parse(rd.Substring(1));
                    int rs1Int = int.Parse(rs1.Substring(1));
                    if (rdInt > 32 || rs1Int > 32 || rs1Int < 0 || rdInt < 0)
                    {
                        MessageBox.Show($"Registrii in afara ariei de lucru! {instructiune}");
                        return;
                    }
                    if (componente[0].EndsWith("i"))
                    {
                        string imm = componente[3];
                        int immInt = int.Parse(imm);
                        if (immInt > 2047 || immInt < -2048)
                        {
                            MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                            return;
                        }
                        if ((immInt > 63 || immInt < 0) & (componente[0] == "slli" || componente[0] == "srli" || componente[0] == "srai"))
                        {
                            MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                            return;
                        }
                        int funct3, funct7;
                        int opcode;
                        switch (componente[0])
                        {
                            case "addi": opcode = 0b0010011; funct7 = 0; funct3 = 0; break;
                            case "slli": opcode = 0b0010011; funct7 = 0; funct3 = 0b001; break;
                            case "slti": opcode = 0b0010011; funct7 = 0; funct3 = 0b010; break;
                            case "xori": opcode = 0b0010011; funct7 = 0; funct3 = 0b100; break;
                            case "ori": opcode = 0b0010011; funct7 = 0; funct3 = 0b110; break;
                            case "andi": opcode = 0b0010011; funct7 = 0; funct3 = 0b111; break;
                            case "srli": opcode = 0b0010011; funct7 = 0; funct3 = 0b101; break;
                            case "srai": opcode = 0b0010011; funct3 = 0b101; funct7 = 0b0100000; break;
                            default: MessageBox.Show($"Operație nesuportată! {instructiune}"); return;
                        }
                        int instrCod = opcode | (rdInt << 7) | (funct3 << 12) | (rs1Int << 15) | (immInt << 20) | (funct7 << 25);
                        textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                    }
                    else if (componente[0] == "sltiu")
                    {
                        string imm = componente[3];
                        int immInt = int.Parse(imm);
                        if (immInt > 2047 || immInt < -2048)
                        {
                            MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                            return;
                        }
                        int funct3 = 0b011, opcode = 0b0010011;
                        int instrCod = opcode | (rdInt << 7) | (funct3 << 12) | (rs1Int << 15) | (immInt << 20);
                        textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                    }
                    else if (_branches.Contains(componente[0]))
                    {
                        string imm = componente[3];
                        int immInt = int.Parse(imm);
                        if (immInt > 2047 || immInt < -2048)
                        {
                            MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                            return;
                        }
                        int opcode = 0b1100011, funct3;
                        switch (componente[0])
                        {
                            case "beq": funct3 = 0b000; break;
                            case "bne": funct3 = 0b001; break;
                            case "blt": funct3 = 0b100; break;
                            case "bge": funct3 = 0b101; break;
                            case "bltu": funct3 = 0b110; break;
                            case "bgeu": funct3 = 0b111; break;
                            default: MessageBox.Show($"Operație nesuportată! {instructiune}"); return;
                        }

                        int instrCod = opcode | (funct3 << 12) | (rdInt << 15) | (rs1Int << 20) | (((immInt >> 12) & 1) << 31) | (((immInt >> 5) & 0b111111) << 25) | (((immInt >> 1) & 0b1111) << 8) | (((immInt >> 11) & 1) << 7);
                        textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                    }
                    else
                    {
                        int funct3, funct7;
                        string rs2 = componente[3].Replace(",", "");
                        if (!rs2.StartsWith("x"))
                        {
                            _registerAlternateName.TryGetValue(rs2, out rs2);
                            if (rs2 == null)
                            {
                                MessageBox.Show($"Nu am găsit echivalent pentru rs2! {instructiune}");
                                return;
                            }
                        }
                        int rs2Int = int.Parse(rs2.Substring(1));
                        if (rs2Int < 0 || rs2Int > 31)
                        {
                            MessageBox.Show($"Registru rs2 înafara ariei de lucru! {instructiune}");
                            return;
                        }
                        int opcode = 0b0110011;
                        switch (componente[0])
                        {
                            case "add": funct7 = 0; funct3 = 0; break;
                            case "sub": funct7 = 0b0100000; funct3 = 0; break;
                            case "sll": funct7 = 0; funct3 = 0b001; break;
                            case "slt": funct7 = 0; funct3 = 0b010; break;
                            case "sltu": funct7 = 0; funct3 = 0b011; break;
                            case "xor": funct7 = 0; funct3 = 0b100; break;
                            case "or": funct7 = 0; funct3 = 0b110; break;
                            case "and": funct7 = 0; funct3 = 0b111; break;
                            case "srl": funct7 = 0; funct3 = 0b101; break;
                            case "sra": funct3 = 0b101; funct7 = 0b0100000; break;
                            default: MessageBox.Show($"Operatie nesuportata! {instructiune}"); return;
                        }
                        int instrCod = opcode | (rdInt << 7) | (funct3 << 12) | (rs1Int << 15) | (rs2Int << 20) | (funct7 << 25);
                        textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                    }
                }
                else if (componente.Length == 3)
                {
                    if (_others.Contains(componente[0]))
                    {
                        string rd = componente[1].Replace(",", "");
                        if (!rd.StartsWith("x"))
                        {
                            _registerAlternateName.TryGetValue(rd, out rd);
                            if (rd == null)
                            {
                                MessageBox.Show($"Nu am găsit echivalent pentru rd! {instructiune}");
                                return;
                            }
                        }
                        int rdInt = int.Parse(rd.Substring(1));
                        if (rdInt < 0 || rdInt > 31)
                        {
                            MessageBox.Show($"Registru rd înafara ariei de lucru! {instructiune}");
                            return;
                        }
                        string imm = componente[2];
                        int immInt = int.Parse(imm);
                        if (immInt > 1048575 || immInt < -1048576)
                        {
                            MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                            return;
                        }
                        int opcode;
                        switch (componente[0])
                        {
                            case "lui": opcode = 0b0110111; break;
                            case "auipc": opcode = 0b0010111; break;
                            default: MessageBox.Show($"Operatie nesuportata! {instructiune}"); return;
                        }
                        int instrCod = opcode | (rdInt << 7) | (immInt << 12);
                        textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                    }
                    else if (_jumps.Contains(componente[0]))
                    {//Jump-uri
                        if (componente[0] == "jal")
                        {
                            int opcode = 0b1101111;
                            string rd = componente[1].Replace(",", "");
                            if (!rd.StartsWith("x"))
                            {
                                _registerAlternateName.TryGetValue(rd, out rd);
                                if (rd == null)
                                {
                                    MessageBox.Show($"Nu am găsit echivalent pentru rd! {instructiune}");
                                    return;
                                }
                            }
                            int rdInt = int.Parse(rd.Substring(1));
                            if (rdInt < 0 || rdInt > 31)
                            {
                                MessageBox.Show($"Registru rd înafara ariei de lucru! {instructiune}");
                                return;
                            }
                            string imm = componente[2];
                            int immInt = int.Parse(imm);
                            if (immInt > 1048575 || immInt < -1048576)
                            {
                                MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                                return;
                            }
                            int instrCod = opcode | (rdInt << 7) | (((immInt >> 20) & 1) << 31) | (((immInt >> 1) & 0b1111111111) << 21) | (((immInt >> 11) & 1) << 20) | (((immInt >> 12) & 0b11111111) << 12);
                            textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                        }
                        else if (componente[0] == "jalr")
                        {
                            int opcode = 0b1100111;
                            string rd = componente[1].Replace(",", "");
                            if (!rd.StartsWith("x"))
                            {
                                _registerAlternateName.TryGetValue(rd, out rd);
                                if (rd == null)
                                {
                                    MessageBox.Show($"Nu am găsit echivalent pentru rd! {instructiune}");
                                    return;
                                }
                            }
                            int rdInt = int.Parse(rd.Substring(1));
                            if (rdInt < 0 || rdInt > 31)
                            {
                                MessageBox.Show($"Registru rd înafara ariei de lucru! {instructiune}");
                                return;
                            }
                            string[] offsetRs1 = componente[2].Split('(');
                            string rs1 = offsetRs1[1].Replace(")", "");
                            if (!rs1.StartsWith("x"))
                            {
                                _registerAlternateName.TryGetValue(rs1, out rs1);
                                if (rs1 == null)
                                {
                                    MessageBox.Show($"Nu am găsit echivalent pentru rs1! {instructiune}");
                                    return;
                                }
                            }
                            int rs1Int = int.Parse(rs1.Substring(1));
                            if (rs1Int < 0 || rs1Int > 31)
                            {
                                MessageBox.Show($"Registru rs1 înafara ariei de lucru! {instructiune}");
                                return;
                            }
                            string imm = offsetRs1[0];
                            int immInt = int.Parse(imm);
                            if (immInt > 2047 || immInt < -2048)
                            {
                                MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                                return;
                            }
                            int instrCod = opcode | (rdInt << 7) | (rs1Int << 15) | (immInt << 20);
                            textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                        }
                    }
                    else if (_loads.Contains(componente[0]))
                    {//Load-uri
                        int opcode = 0b0000011, funct3;
                        string rd = componente[1].Replace(",", "");
                        if (!rd.StartsWith("x"))
                        {
                            _registerAlternateName.TryGetValue(rd, out rd);
                            if (rd == null)
                            {
                                MessageBox.Show($"Nu am găsit echivalent pentru rd! {instructiune}");
                                return;
                            }
                        }
                        int rdInt = int.Parse(rd.Substring(1));
                        if (rdInt < 0 || rdInt > 31)
                        {
                            MessageBox.Show($"Registru rd înafara ariei de lucru! {instructiune}");
                            return;
                        }
                        string[] offsetRs1 = componente[2].Split('(');
                        string rs1 = offsetRs1[1].Replace(")", "");
                        if (!rs1.StartsWith("x"))
                        {
                            _registerAlternateName.TryGetValue(rs1, out rs1);
                            if (rs1 == null)
                            {
                                MessageBox.Show($"Nu am găsit echivalent pentru rs1! {instructiune}");
                                return;
                            }
                        }
                        int rs1Int = int.Parse(rs1.Substring(1));
                        if (rs1Int < 0 || rs1Int > 31)
                        {
                            MessageBox.Show($"Registru rs1 înafara ariei de lucru! {instructiune}");
                            return;
                        }
                        string imm = offsetRs1[0];
                        int immInt = int.Parse(imm);
                        if (immInt > 2047 || immInt < -2048)
                        {
                            MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                            return;
                        }
                        switch (componente[0])
                        {
                            case "lb": funct3 = 0; break;
                            case "lh": funct3 = 0b001; break;
                            case "lw": funct3 = 0b010; break;
                            case "ld": funct3 = 0b011; break;
                            case "lbu": funct3 = 0b100; break;
                            case "lhu": funct3 = 0b101; break;
                            case "lwu": funct3 = 0b110; break;
                            default: MessageBox.Show($"Operatie nesuportata! {instructiune}"); return;
                        }
                        int instrCod = opcode | (rdInt << 7) | (rs1Int << 15) | (immInt << 20) | (funct3 << 12);
                        textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                    }
                    else if (_stores.Contains(componente[0]))
                    {//Store-uri
                        int opcode = 0b0100011, funct3;
                        string rs2 = componente[1].Replace(",", "");
                        if (!rs2.StartsWith("x"))
                        {
                            _registerAlternateName.TryGetValue(rs2, out rs2);
                            if (rs2 == null)
                            {
                                MessageBox.Show($"Nu am găsit echivalent pentru rd! {instructiune}");
                                return;
                            }
                        }
                        int rs2Int = int.Parse(rs2.Substring(1));
                        if (rs2Int < 0 || rs2Int > 31)
                        {
                            MessageBox.Show($"Registru rs2 înafara ariei de lucru! {instructiune}");
                            return;
                        }
                        string[] offsetRs1 = componente[2].Split('(');
                        string rs1 = offsetRs1[1].Replace(")", "");
                        if (!rs1.StartsWith("x"))
                        {
                            _registerAlternateName.TryGetValue(rs1, out rs1);
                            if (rs1 == null)
                            {
                                MessageBox.Show($"Nu am găsit echivalent pentru rs1! {instructiune}");
                                return;
                            }
                        }
                        int rs1Int = int.Parse(rs1.Substring(1));
                        if (rs1Int < 0 || rs1Int > 31)
                        {
                            MessageBox.Show($"Registru rs1 înafara ariei de lucru! {instructiune}");
                            return;
                        }
                        string imm = offsetRs1[0];
                        int immInt = int.Parse(imm);
                        if (immInt > 2047 || immInt < -2048)
                        {
                            MessageBox.Show($"Valoare prea mare sau mică pentru imm! {instructiune}");
                            return;
                        }
                        switch (componente[0])
                        {
                            case "sb": funct3 = 0; break;
                            case "sh": funct3 = 0b001; break;
                            case "sw": funct3 = 0b010; break;
                            case "sd": funct3 = 0b011; break;
                            default: MessageBox.Show($"Operatie nesuportata! {instructiune}"); return;
                        }
                        int instrCod = opcode | (rs2Int << 20) | (rs1Int << 15) | (funct3 << 12) | ((immInt & 0b11111) << 7) | (((immInt >> 5) & 0b1111111) << 25);
                        textBoxInput.AppendText($"{instrCod.ToString("X8")}  {instructiune}" + Environment.NewLine);
                    }
                    else
                    {
                        MessageBox.Show($"Format incorect sau instructiune nesuportată! {instructiune}");
                    }
                }
                else
                {
                    MessageBox.Show($"Format incorect sau instructiune nesuportată! {instructiune}");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
