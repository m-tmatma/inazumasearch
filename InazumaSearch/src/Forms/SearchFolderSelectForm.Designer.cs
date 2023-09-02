﻿namespace InazumaSearch.Forms
{
    partial class SearchFolderSelectForm
    {
        /// <summary>
        /// 必要なデザイナー変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージ リソースを破棄する場合は true を指定し、その他の場合は false を指定します。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows フォーム デザイナーで生成されたコード

        /// <summary>
        /// デザイナー サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディターで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.BtnCancel = new System.Windows.Forms.Button();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.TreeFolder = new System.Windows.Forms.TreeView();
            this.delayTimer = new System.Windows.Forms.Timer(this.components);
            this.TxtTarget = new System.Windows.Forms.TextBox();
            this.BtnDecide = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.ChkCrawlFolderOnly = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // BtnCancel
            // 
            this.BtnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.BtnCancel.Location = new System.Drawing.Point(1223, 543);
            this.BtnCancel.Margin = new System.Windows.Forms.Padding(4);
            this.BtnCancel.Name = "BtnCancel";
            this.BtnCancel.Size = new System.Drawing.Size(133, 50);
            this.BtnCancel.TabIndex = 15;
            this.BtnCancel.Text = "キャンセル";
            this.BtnCancel.UseVisualStyleBackColor = true;
            this.BtnCancel.Click += new System.EventHandler(this.BtnClose_Click);
            // 
            // TreeFolder
            // 
            this.TreeFolder.Location = new System.Drawing.Point(37, 90);
            this.TreeFolder.Margin = new System.Windows.Forms.Padding(4);
            this.TreeFolder.Name = "TreeFolder";
            this.TreeFolder.Size = new System.Drawing.Size(430, 413);
            this.TreeFolder.TabIndex = 16;
            this.TreeFolder.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.TreeFolder_AfterSelect);
            this.TreeFolder.DoubleClick += new System.EventHandler(this.TreeFolder_DoubleClick);
            // 
            // delayTimer
            // 
            this.delayTimer.Enabled = true;
            this.delayTimer.Tick += new System.EventHandler(this.delayTimer_Tick);
            // 
            // TxtTarget
            // 
            this.TxtTarget.Location = new System.Drawing.Point(503, 90);
            this.TxtTarget.Multiline = true;
            this.TxtTarget.Name = "TxtTarget";
            this.TxtTarget.Size = new System.Drawing.Size(847, 413);
            this.TxtTarget.TabIndex = 17;
            // 
            // BtnDecide
            // 
            this.BtnDecide.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.BtnDecide.Location = new System.Drawing.Point(1026, 543);
            this.BtnDecide.Margin = new System.Windows.Forms.Padding(4);
            this.BtnDecide.Name = "BtnDecide";
            this.BtnDecide.Size = new System.Drawing.Size(158, 50);
            this.BtnDecide.TabIndex = 18;
            this.BtnDecide.Text = "確定";
            this.BtnDecide.UseVisualStyleBackColor = true;
            this.BtnDecide.Click += new System.EventHandler(this.BtnDecide_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(33, 22);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(577, 23);
            this.label1.TabIndex = 19;
            this.label1.Text = "ツリー内のフォルダをダブルクリックして、検索対象とするフォルダを選択してください。";
            // 
            // ChkCrawlFolderOnly
            // 
            this.ChkCrawlFolderOnly.AutoSize = true;
            this.ChkCrawlFolderOnly.Location = new System.Drawing.Point(37, 510);
            this.ChkCrawlFolderOnly.Name = "ChkCrawlFolderOnly";
            this.ChkCrawlFolderOnly.Size = new System.Drawing.Size(261, 27);
            this.ChkCrawlFolderOnly.TabIndex = 20;
            this.ChkCrawlFolderOnly.Text = "クロール対象のフォルダのみ表示";
            this.ChkCrawlFolderOnly.UseVisualStyleBackColor = true;
            this.ChkCrawlFolderOnly.CheckedChanged += new System.EventHandler(this.ChkCrawlFolderOnly_CheckedChanged);
            // 
            // SearchFolderSelectForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(144F, 144F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.ClientSize = new System.Drawing.Size(1374, 612);
            this.Controls.Add(this.ChkCrawlFolderOnly);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.BtnDecide);
            this.Controls.Add(this.TxtTarget);
            this.Controls.Add(this.TreeFolder);
            this.Controls.Add(this.BtnCancel);
            this.Font = new System.Drawing.Font("Meiryo UI", 9F);
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "SearchFolderSelectForm";
            this.Text = "検索対象フォルダ選択";
            this.Load += new System.EventHandler(this.SearchFolderSelectForm_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Button BtnCancel;
        private System.Windows.Forms.ToolTip toolTip1;
        private System.Windows.Forms.TreeView TreeFolder;
        private System.Windows.Forms.Timer delayTimer;
        private System.Windows.Forms.TextBox TxtTarget;
        private System.Windows.Forms.Button BtnDecide;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox ChkCrawlFolderOnly;
    }
}

