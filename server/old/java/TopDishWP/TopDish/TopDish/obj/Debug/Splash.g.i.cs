﻿#pragma checksum "C:\Users\dankurc\Documents\Expression\Blend 4\Projects\TopDish\TopDish\Splash.xaml" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "59229814B6D5BF829C4164687EE3BA04"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.225
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using Microsoft.Phone.Controls;
using System;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Automation.Peers;
using System.Windows.Automation.Provider;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Resources;
using System.Windows.Shapes;
using System.Windows.Threading;


namespace TopDish {
    
    
    public partial class MainPage : Microsoft.Phone.Controls.PhoneApplicationPage {
        
        internal Microsoft.Phone.Controls.PhoneApplicationPage Splash;
        
        internal System.Windows.Controls.Grid LayoutRoot;
        
        internal System.Windows.Controls.Grid ContentPanel;
        
        internal System.Windows.Controls.TextBlock txtLoading;
        
        internal System.Windows.Controls.ProgressBar progressBar;
        
        internal System.Windows.Controls.Button startButton;
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Windows.Application.LoadComponent(this, new System.Uri("/TopDish;component/Splash.xaml", System.UriKind.Relative));
            this.Splash = ((Microsoft.Phone.Controls.PhoneApplicationPage)(this.FindName("Splash")));
            this.LayoutRoot = ((System.Windows.Controls.Grid)(this.FindName("LayoutRoot")));
            this.ContentPanel = ((System.Windows.Controls.Grid)(this.FindName("ContentPanel")));
            this.txtLoading = ((System.Windows.Controls.TextBlock)(this.FindName("txtLoading")));
            this.progressBar = ((System.Windows.Controls.ProgressBar)(this.FindName("progressBar")));
            this.startButton = ((System.Windows.Controls.Button)(this.FindName("startButton")));
        }
    }
}

