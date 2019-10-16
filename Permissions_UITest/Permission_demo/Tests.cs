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
                //.AppBundle("/Users/ahanag22/Desktop/Permissions/Products/app/Permissions.app")
              .StartApp();
        }




        //Adding Xamarin.UITest tests to the project https://github.com/calabash/Permissions
        // App displays iOS privacy settings menu items// tapping each privacy settings menu items that pops up an alert
        // checking if the popup is being handled by the logic
        // the logic for dismissing popups does recognize the text of the popups 
        // checked only the popups we've added to our logic here https://github.com/calabash/DeviceAgent.iOS/blob/develop/Server/Utilities/SpringBoardAlerts.m



        [Test]
        public void AlertShowsUpForContacts()
        {
            // tapping menu item
            app.Tap(x => x.Marked("contacts"));
            //taking a screenshot
            app.Screenshot("Show Alert for contacts");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }



        [Test]
        public void AlertShowsUpForReminder()
        {
            // tapping menu item
            app.Tap(x => x.Marked("reminders"));
            //taking a screenshot
            app.Screenshot("Show Alert for reminders");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }

        [Test]
        public void AlertShowsUpForMicrophone()
        {
            // tapping menu item
            app.Tap(x => x.Marked("microphone"));
            //taking a screenshot
            app.Screenshot("Show Alert for microphone");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }

        [Test]
        public void AlertShowsUpForMotion()
        {
            // tapping menu item
            app.Tap(x => x.Marked("motion"));
            //taking a screenshot
            app.Screenshot("Show Alert for motion");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }

        [Test]
        public void AlertShowsUpForAPNS()
        {
            app.ScrollDown();
            // tapping menu item
            app.Tap(x => x.Marked("apns"));
            //taking a screenshot
            app.Screenshot("Show Alert for apns");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }


        [Test]
        public void AlertShowsUpForAppleMusic()
        {
            app.ScrollDown();
            // tapping menu item
            app.Tap(x => x.Marked("apple music"));
            //taking a screenshot
            app.Screenshot("Show Alert for apple music");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }


        [Test]
        public void AlertShowsUpForSpeechRecognition()
        {
            app.ScrollDown();
            // tapping menu item
            app.Tap(x => x.Marked("speech recognition"));
            //taking a screenshot
            app.Screenshot("Show Alert for speech recognition");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }


        [Test]
        public void AlertShowsUpForTwitter()
        {
            app.ScrollDown();
            // tapping menu item
            app.Tap(x => x.Marked("twitter"));
            //taking a screenshot
            app.Screenshot("Show Alert for twitter");
            app.DismissSpringboardAlerts();
            Thread.Sleep(5 * 1000);
            //chekcing if the alert has been dismissed
            app.Screenshot("Alert dismissed");
        }
    }

}