﻿#pragma checksum "C:\Users\dankurc\Documents\Expression\Blend 4\Projects\TopDish\TopDish\Pages\Welcome.xaml" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "6BC2C12EFAE4283A5E064A715AE3B958"
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


namespace TopDish.Pages {
    
    
    public partial class Welcome : Microsoft.Phone.Controls.PhoneApplicationPage {
        
        internal System.Windows.Controls.Grid LayoutRoot;
        
        internal System.Windows.Controls.Grid SearchBar;
        
        internal System.Windows.Controls.TextBox searchText;
        
        internal System.Windows.Controls.Button btnSearch;
        
        internal System.Windows.Controls.Grid ContentPanel;
        
        internal System.Windows.Controls.Button btnNearest;
        
        internal System.Windows.Controls.Button btnRate;
        
        internal System.Windows.Controls.Button btnProfile;
        
        internal System.Windows.Controls.Button btnMap;
        
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
            System.Windows.Application.LoadComponent(this, new System.Uri("/TopDish;component/Pages/Welcome.xaml", System.UriKind.Relative));
            this.LayoutRoot = ((System.Windows.Controls.Grid)(this.FindName("LayoutRoot")));
            this.SearchBar = ((System.Windows.Controls.Grid)(this.FindName("SearchBar")));
            this.searchText = ((System.Windows.Controls.TextBox)(this.FindName("searchText")));
            this.btnSearch = ((System.Windows.Controls.Button)(this.FindName("btnSearch")));
            this.ContentPanel = ((System.Windows.Controls.Grid)(this.FindName("ContentPanel")));
            this.btnNearest = ((System.Windows.Controls.Button)(this.FindName("btnNearest")));
            this.btnRate = ((System.Windows.Controls.Button)(this.FindName("btnRate")));
            this.btnProfile = ((System.Windows.Controls.Button)(this.FindName("btnProfile")));
            this.btnMap = ((System.Windows.Controls.Button)(this.FindName("btnMap")));
        }
    }
}
