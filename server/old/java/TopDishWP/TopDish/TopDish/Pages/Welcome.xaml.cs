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

namespace TopDish.Pages
{
    public partial class Welcome : PhoneApplicationPage
    {
        public Welcome()
        {
            InitializeComponent();
        }

        private void btnNearest_Click(object sender, RoutedEventArgs e)
        {
            // at this point for now we'll navigate to the welcome screen
            //navigate
            this.NavigationService.Navigate(new Uri("/Pages/Nearest.xaml", UriKind.Relative));
        }

        private void btnRate_Click(object sender, RoutedEventArgs e)
        {
            // at this point for now we'll navigate to the rate screen
            //navigate
            this.NavigationService.Navigate(new Uri("/Pages/RateDish.xaml", UriKind.Relative));
        }

        private void btnProfile_Click(object sender, RoutedEventArgs e)
        {
            // at this point for now we'll navigate to the Profile screen
            //navigate
            this.NavigationService.Navigate(new Uri("/Pages/Profile.xaml", UriKind.Relative));
        }

        private void btnMap_Click(object sender, RoutedEventArgs e)
        {
            // at this point for now we'll navigate to the Map Screen
            //navigate
            this.NavigationService.Navigate(new Uri("/Pages/Welcome.xaml", UriKind.Relative));
        }


    }
}