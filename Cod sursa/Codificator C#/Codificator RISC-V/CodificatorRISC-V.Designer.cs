
namespace Codificator_RISC_V
{
    partial class CodificatorRISCV
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(CodificatorRISCV));
            this.textBoxInput = new System.Windows.Forms.TextBox();
            this.buttonSal = new System.Windows.Forms.Button();
            this.textBoxInstr = new System.Windows.Forms.TextBox();
            this.buttonCod = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.buttonInstr = new System.Windows.Forms.Button();
            this.saveFileDialog = new System.Windows.Forms.SaveFileDialog();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.label10 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.buttonIncFis = new System.Windows.Forms.Button();
            this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.buttonDel = new System.Windows.Forms.Button();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // textBoxInput
            // 
            this.textBoxInput.Location = new System.Drawing.Point(303, 12);
            this.textBoxInput.Multiline = true;
            this.textBoxInput.Name = "textBoxInput";
            this.textBoxInput.ReadOnly = true;
            this.textBoxInput.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textBoxInput.Size = new System.Drawing.Size(252, 341);
            this.textBoxInput.TabIndex = 3;
            // 
            // buttonSal
            // 
            this.buttonSal.Location = new System.Drawing.Point(149, 88);
            this.buttonSal.Name = "buttonSal";
            this.buttonSal.Size = new System.Drawing.Size(148, 40);
            this.buttonSal.TabIndex = 4;
            this.buttonSal.Text = "Salvare în fișier input";
            this.buttonSal.UseVisualStyleBackColor = true;
            this.buttonSal.Click += new System.EventHandler(this.buttonSal_Click);
            // 
            // textBoxInstr
            // 
            this.textBoxInstr.Location = new System.Drawing.Point(3, 45);
            this.textBoxInstr.Name = "textBoxInstr";
            this.textBoxInstr.Size = new System.Drawing.Size(140, 20);
            this.textBoxInstr.TabIndex = 1;
            // 
            // buttonCod
            // 
            this.buttonCod.Location = new System.Drawing.Point(3, 88);
            this.buttonCod.Name = "buttonCod";
            this.buttonCod.Size = new System.Drawing.Size(140, 40);
            this.buttonCod.TabIndex = 2;
            this.buttonCod.Text = "Codificare instructiune";
            this.buttonCod.UseVisualStyleBackColor = true;
            this.buttonCod.Click += new System.EventHandler(this.buttonCod_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(0, 29);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(123, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "Instrucțiune de codificat:";
            // 
            // label2
            // 
            this.label2.Location = new System.Drawing.Point(3, 10);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(180, 21);
            this.label2.TabIndex = 0;
            this.label2.Text = "Format instrucțiuni R: op rd, rs1, rs2";
            // 
            // buttonInstr
            // 
            this.buttonInstr.Location = new System.Drawing.Point(149, 27);
            this.buttonInstr.Name = "buttonInstr";
            this.buttonInstr.Size = new System.Drawing.Size(148, 38);
            this.buttonInstr.TabIndex = 3;
            this.buttonInstr.Text = "Salvare în fișier instruction";
            this.buttonInstr.UseVisualStyleBackColor = true;
            this.buttonInstr.Click += new System.EventHandler(this.buttonInstr_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(3, 30);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(172, 13);
            this.label3.TabIndex = 7;
            this.label3.Text = "Format instrucțiuni I: op rd, rs1, imm";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(3, 50);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(207, 13);
            this.label4.TabIndex = 8;
            this.label4.Text = "Format instrucțiuni branch: op rs1, rs2, imm";
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.label10);
            this.panel1.Controls.Add(this.label9);
            this.panel1.Controls.Add(this.label8);
            this.panel1.Controls.Add(this.label7);
            this.panel1.Controls.Add(this.label6);
            this.panel1.Controls.Add(this.label5);
            this.panel1.Controls.Add(this.label2);
            this.panel1.Controls.Add(this.label4);
            this.panel1.Controls.Add(this.label3);
            this.panel1.Location = new System.Drawing.Point(3, 134);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(282, 219);
            this.panel1.TabIndex = 9;
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(3, 176);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(258, 26);
            this.label10.TabIndex = 14;
            this.label10.Text = "Fișier instruction: Salvare în format little endian pentru\r\n                     " +
    "      executare pe procesor";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(3, 150);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(240, 26);
            this.label9.TabIndex = 13;
            this.label9.Text = "Fișier input: Salvare codificare în format explicativ\r\n                    big en" +
    "dian";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(3, 130);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(187, 13);
            this.label8.TabIndex = 12;
            this.label8.Text = "Format instrucțiune jalr: jalr rd, imm(rs1)";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(3, 110);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(214, 13);
            this.label7.TabIndex = 11;
            this.label7.Text = "Format instrucțiuni lui, auipc și jal: op rd, imm";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(3, 90);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(192, 13);
            this.label6.TabIndex = 10;
            this.label6.Text = "Format instrucțiuni store: op rd, imm(rs1)";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(3, 70);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(189, 13);
            this.label5.TabIndex = 9;
            this.label5.Text = "Format instrucțiuni load: op rd, imm(rs1)";
            // 
            // buttonIncFis
            // 
            this.buttonIncFis.Location = new System.Drawing.Point(3, 3);
            this.buttonIncFis.Name = "buttonIncFis";
            this.buttonIncFis.Size = new System.Drawing.Size(140, 23);
            this.buttonIncFis.TabIndex = 10;
            this.buttonIncFis.Text = "Încărcare fișier";
            this.buttonIncFis.UseVisualStyleBackColor = true;
            this.buttonIncFis.Click += new System.EventHandler(this.buttonIncFis_Click);
            // 
            // buttonDel
            // 
            this.buttonDel.Location = new System.Drawing.Point(149, 3);
            this.buttonDel.Name = "buttonDel";
            this.buttonDel.Size = new System.Drawing.Size(148, 23);
            this.buttonDel.TabIndex = 11;
            this.buttonDel.Text = "Eliminare conținut";
            this.buttonDel.UseVisualStyleBackColor = true;
            this.buttonDel.Click += new System.EventHandler(this.buttonDel_Click);
            // 
            // CodificatorRISCV
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(567, 365);
            this.Controls.Add(this.buttonDel);
            this.Controls.Add(this.buttonIncFis);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.buttonInstr);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.buttonCod);
            this.Controls.Add(this.textBoxInstr);
            this.Controls.Add(this.buttonSal);
            this.Controls.Add(this.textBoxInput);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "CodificatorRISCV";
            this.Text = "Codificator RISC-V RV64I";
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox textBoxInput;
        private System.Windows.Forms.Button buttonSal;
        private System.Windows.Forms.TextBox textBoxInstr;
        private System.Windows.Forms.Button buttonCod;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button buttonInstr;
        private System.Windows.Forms.SaveFileDialog saveFileDialog;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Button buttonIncFis;
        private System.Windows.Forms.OpenFileDialog openFileDialog;
        private System.Windows.Forms.Button buttonDel;
    }
}

