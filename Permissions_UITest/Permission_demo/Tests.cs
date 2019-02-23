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


        // adding Xamarin.UITest tests to the project https://github.com/calabash/Permissions
        // The test automates the tapping on the privacy settings menu
        // checking if the the popups have been dismissed by the logic here https://github.com/calabash/DeviceAgent.iOS/blob/develop/Server/Utilities/SpringBoardAlerts.m

        [Test]
        public void AlertShowsUpForBackgroundLocation()
        {
            app.Tap(x => x.Marked("background location"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");

        }

        [Test]
        public void AlertShowsUpForContacts()
        {
            app.Tap(x => x.Marked("contacts"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");

        }

        [Test]
        public void AlertShowsUpForCalender()
        {
            app.Tap(x => x.Marked("calendar"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
       }

        [Test]
        public void AlertShowsUpForReminders()
        {
            app.Tap(x => x.Marked("reminders"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForMicrophone()
        {
            app.Tap(x => x.Marked("microphone"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForMotion()
        {
            app.Tap(x => x.Marked("motion"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForCamera()
        {
            app.ScrollDown();
            app.Tap(x => x.Marked("camera"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForBluetooth()
        {
            app.ScrollDown();
            app.Tap(x => x.Marked("bluetooth"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForTwitter()
        {
            app.ScrollDown();
            app.Tap(x => x.Marked("twitter"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForAPNS()
        {
            app.ScrollDown();
            app.Tap(x => x.Marked("apns"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }


        [Test]
        public void AlertShowsUpForAppleMusic()
        {
            app.ScrollDown();
            app.Tap(x => x.Marked("apple music"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForSpeechRecognition()
        {
            app.ScrollDown();
            app.Tap(x => x.Marked("speech recognition"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForHealthKit()
        {
            app.ScrollDown();
            app.Tap(x => x.Marked("health kit"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }

        [Test]
        public void AlertShowsUpForPhotos(){

            app.Tap(x => x.Marked("photos"));
            app.Screenshot("Show Alert");
            app.DismissSpringboardAlerts();
            app.Screenshot("alert dismissed");
        }


    }

}