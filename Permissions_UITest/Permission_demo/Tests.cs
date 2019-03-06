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
              .AppBundle("/Users/ahanag22/Desktop/Permissions/Products/app/Permissions.app")
              .StartApp();

        }

        public bool IsAlertVisible()
        {

            return app.Query(c => c.ClassFull("_UIAlertControllerView")).Any();

        }

        public void helperMethod(String s)
        {
            //loop until timeout(20 secs?) :
            //tap the element
            //wait for alert(1 sec?)
            //if alert found - exit loop
            //sleep 1 sec

            bool IsVisible = false;
            for (int i = 0; i <= 20; i++)
            {
                app.Tap(x => x.Marked(s));
                Thread.Sleep(1000);
                if (IsAlertVisible())
                {

                    app.Screenshot("Alert Appeared");
                    IsVisible = true;
                    break;
                }

                Thread.Sleep(1000);

            }
            if (!IsVisible)
            {
                app.Screenshot("Alert has not been appeared");
            }
            if (IsVisible)
            {
                Thread.Sleep(5 * 1000);
                if (!IsAlertVisible())
                {
                    app.Screenshot("Alert has been disappeared");
                }
                else
                {
                    app.Screenshot("Alert has not been disappeared");
                }
            }
        }

        // adding Xamarin.UITest tests to the project https://github.com/calabash/Permissions
        // The test automates the tapping on the privacy settings menu
        // checking if the the popups have been dismissed by the logic here https://github.com/calabash/DeviceAgent.iOS/blob/develop/Server/Utilities/SpringBoardAlerts.m

        [Test]
        public void AlertShowsUpForBackgroundLocation()
        {
            String s = "background location";
            helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForContacts()
        {
            String s = "contacts";
            helperMethod(s);

        }

         [Test]
         public void AlertShowsUpForCalender()
         {
             String s = "calendar";
             helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForReminders()
        {
            String s = "reminders";
            helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForMicrophone()
        {
            String s = "microphone";
            helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForMotion()
        {
            String s = "motion";
            helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForCamera()
        {
            app.ScrollDown();
            String s = "camera";
            helperMethod(s);
        }

        //[Test]
        //public void AlertShowsUpForBluetooth()
        //{
        //    app.ScrollDown();
        //    app.Tap(x => x.Marked("bluetooth"));
        //    app.Screenshot("After tapping the menu item blutooth");

        //}


        [Test]
        public void AlertShowsUpForTwitter()
        {
            app.ScrollDown();
            String s = "twitter";
            helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForAPNS()
        {
            app.ScrollDown();
            String s = "apns";
            helperMethod(s);
        }


        [Test]
        public void AlertShowsUpForAppleMusic()
        {
            app.ScrollDown();
            String s = "apple music";
            helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForSpeechRecognition()
        {
            app.ScrollDown();
            String s = "speech recognition";
            helperMethod(s);
        }

        [Test]
        public void AlertShowsUpForHealthKit()
        {
            app.ScrollDown();
            String s = "health kit";
            helperMethod(s);
            //app.Repl();

        }

        [Test]
        public void AlertShowsUpForPhotos()
        {

            app.Tap(x => x.Marked("photos"));
            app.Screenshot("After tapping menu item Photos");
            //app.Repl();
            app.Tap(c => c.Class("UILabel").Text("Cancel"));

        }


    }

}