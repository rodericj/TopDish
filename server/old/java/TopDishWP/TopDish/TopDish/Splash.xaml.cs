using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using System.Windows.Threading;

namespace TopDish
{
    public partial class MainPage : PhoneApplicationPage
    {

        private DispatcherTimer timer;
        private uint pctComplete = 0;

        public MainPage()
        {
            InitializeComponent();
        }

        private void ContentPanel_Loaded(object sender, RoutedEventArgs e)
        {
            timer = new DispatcherTimer();
            timer.Interval = TimeSpan.FromMilliseconds(10);
            timer.Tick += new EventHandler(loadProgress);

            progressBar.Minimum = 0;
            progressBar.Maximum = 100;
            timer.Start();
        }

        private void loadProgress(object sender, EventArgs e)
        {
            pctComplete++;
            if (pctComplete == 100)
            {
                // do whatever we do when we're loaded
                timer.Start();
                startButton.Visibility = System.Windows.Visibility.Visible;
                progressBar.Visibility = System.Windows.Visibility.Collapsed;
                txtLoading.Visibility = System.Windows.Visibility.Collapsed;
            }
            progressBar.Value = pctComplete;
        }

        private void startButton_Click(object sender, RoutedEventArgs e)
        {
            // at this point for now we'll navigate to the welcome screen
            //navigate
            this.NavigationService.Navigate(new Uri("/Pages/Welcome.xaml", UriKind.Relative));
        }
    }
}
