using System;
using System.IO;
using System.Linq;
using System.Threading;
using NUnit.Framework;
using Xamarin.UITest;
using Xamarin.UITest.iOS;
using Xamarin.UITest.Queries;

namespace Permission_demo
{
    [TestFixture]
    public class Tests
    {
        iOSApp app;

        [SetUp]
        public void BeforeEachTest()
        {
            // TODO: If the iOS app being tested is included in the solution then open
            // the Unit Tests window, right click Test Apps, select Add App Project
            // and select the app projects that should be tested.
            //
            // The iOS project should have the Xamarin.TestCloud.Agent NuGet package
            // installed. To start the Test Cloud Agent the following code should be
            // added to the FinishedLaunching method of the AppDelegate:
            //
            //    #if ENABLE_TEST_CLOUD
            //    Xamarin.Calabash.Start();
            //    #endif
            app = ConfigureApp
                .iOS
               // TODO: Update this path to point to your iOS app and uncomment the
               // code if the app is not included in the solution.
               //.AppBundle("../../../../../Permissions.app")
              .StartApp();
               
        }

      
        //adding Xamarin.UITest tests to the project https://github.com/calabash/Permissions
        //App displays iOS privacy settings menu items
        //tapping each privacy settings menu items that pops up an alert
        //checking if the popup is being handled by the logic
        //the logic for dismissing popups does recognize the text of the popups 
        //checked only the popups alerady been added to the logic here https://github.com/calabash/DeviceAgent.iOS/blob/develop/Server/Utilities/SpringBoardAlerts.m

        [Test]
        public void AlertShowsUp()
        {

            //creating an anrray of menu items:
            string[] stringArray = new string[12];
            stringArray[0] = "background location";
            stringArray[1] = "contacts";
            stringArray[2] = "calendar";
            stringArray[3] = "reminders";
            stringArray[4] = "microphone";
            stringArray[5] = "motion";
            stringArray[6] = "camera";
            stringArray[7] = "twitter";
            stringArray[8] = "apns";
            stringArray[9] = "apple music";
            stringArray[10] = "speech recognition";
            stringArray[11] = "health kit";
           

            for (int i = 0; i < stringArray.Length; i++)
            {
                //tapping each menu item
                app.Tap(x => x.Marked(stringArray[i]));
                //taking the screenshot
                app.Screenshot("Show Alert for " + stringArray[i]);
                //There is generally no need to call DismissSpringboardAlerts()in user test code, I'm calling this method to play it safe
                app.DismissSpringboardAlerts();
                app.Screenshot("alert dismissed"); 
                //adding a sleep of 10 seconds before tapping the next menu item to give the UI time to be ready
                Thread.Sleep(5*1000);
                if (i >= 6)
                {
                    app.ScrollDown();

                }
               
            }

        }

        //checking separtely since tapping on photos naviagating to a new screen

        [Test]
        public void AlertShowsUpForPhotos(){
       
            app.Tap(x => x.Marked("photos"));
            app.Screenshot("Alert shows up");

        }

       


    }

}

