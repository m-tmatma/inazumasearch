﻿using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Windows.Forms;
using InazumaSearch.Core;
using InazumaSearch.Forms;

namespace InazumaSearch
{
    public partial class MainComponent : Component
    {
        public Core.Application App { get; set; }
        protected bool MemoryOverflowWarningShowing { get; set; } = false;
        protected bool MemoryOverflowWarningSkipped { get; set; } = false;

        public MainComponent()
        {
            InitializeComponent();

            System.Windows.Forms.Application.ApplicationExit += Application_ApplicationExit;

        }

        private void Application_ApplicationExit(object sender, EventArgs e)
        {
            NotifyIcon.Dispose();
        }

        public MainComponent(Core.Application app) : this()
        {
            App = app;
        }

        private void NotifyIcon_MouseDoubleClick(object sender, System.Windows.Forms.MouseEventArgs e)
        {
            StartBrowser();
        }

        public void StartBrowser()
        {
            try
            {
                var form = new BrowserForm(App.HtmlDirPath)
                {
                    App = App
                };
                Core.Application.BootingBrowserForms.Add(form);
                form.Show();
            }
            catch (System.IO.FileNotFoundException ex)
            {
                App.Logger.Error(ex);
                App.Logger.Error($"見つからなかったファイル: {ex.FileName}");
                App.Logger.Error($"FusionLog: {ex.FusionLog}");
                Util.ShowErrorMessage("必要なファイルが読み込めなかったため、ブラウザコントロールの初期化に失敗しました。");
                Core.Application.Quit();
            }
        }

        protected void MenuItem_Quit_Click(object sender, EventArgs e)
        {
            Core.Application.Quit();
        }


        private void TaskBarContextMenu_Opening(object sender, CancelEventArgs e)
        {

        }

        private void MenuItem_WindowOpen_Click(object sender, EventArgs e)
        {
            StartBrowser();
        }

        private void ProcessMonitoringTimer_Tick(object sender, EventArgs e)
        {
            try
            {
                // プロセス情報を取得
                var proc = Process.GetCurrentProcess();
                proc.Refresh(); // キャッシュクリア

                // 物理RAM使用量と、ページングファイル使用量を取得
                var workingSet = proc.WorkingSet64;
                var pagedMemorySize = proc.PagedMemorySize64;

                // どちらか片方でも1GBを超えたら警告
                var threshold = 1024 * 1024 * 1000;
                if (workingSet > threshold || pagedMemorySize > threshold)
                {
                    if (!MemoryOverflowWarningSkipped && !MemoryOverflowWarningShowing)
                    {
                        MemoryOverflowWarningShowing = true;
                        try
                        {
                            var mainForm = Core.Application.BootingBrowserForms.LastOrDefault();
                            if (mainForm != null) mainForm.Activate();
                            var msg = $"" +
                                $"Inazuma Searchのメモリ使用量が非常に大きくなっており、これ以上起動し続けると、PC全体の処理が重くなってしまう可能性があります。\n" +
                                $"（物理RAM使用量：{Util.FormatFileSizeByMB(workingSet)}、ページングファイル使用量：{Util.FormatFileSizeByMB(pagedMemorySize)}）\n" +
                                $"\n" +
                                $"この問題は、Inazuma Searchを再起動することによって改善される可能性があります。\n" +
                                $"Inazuma Searchを再起動してもよろしいですか？";
                            if ((mainForm != null ? Util.Confirm(mainForm, msg) : Util.Confirm(msg)))
                            {
                                Core.Application.Restart();
                            }
                            else
                            {
                                MemoryOverflowWarningSkipped = true;
                            }
                        }
                        finally
                        {
                            MemoryOverflowWarningShowing = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                this.App.Logger.Warn(ex);
            }

            try
            {
                // 常駐クロールONの設定で、常駐クロールのプロセスが終了しており、かつ中断フラグがOFFなら再起動
                if (App.UserSettings.AlwaysCrawlMode
                && !App.Crawler.AlwaysCrawlIsRunning
                && !App.Crawler.AlwaysCrawlAutoRebootDisabled)
                {
                    this.App.Logger.Warn("常駐クローラが終了しているため再起動します...");
                    App.Crawler.StartAlwaysCrawl();
                }
            }
            catch (Exception ex)
            {
                this.App.Logger.Warn(ex);
            }
        }
    }
}
