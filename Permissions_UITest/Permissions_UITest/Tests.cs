using System;
using System.IO;
using System.Linq;
using NUnit.Framework;
using Xamarin.UITest.iOS;
using Xamarin.UITest;
using System.Threading;
using Xamarin.UITest.Queries;
using System.Collections.Generic;
using Newtonsoft.Json;

public class UIElement
{
    public string id { get; set; }
    public bool has_focus { get; set; }
    public string label { get; set; }
    public string type { get; set; }
    public string title { get; set; }
    public string value { get; set; }
    public Dictionary<string, int> hit_point { get; set; }
    public bool enabled { get; set; }
    public string placeholder { get; set; }
    public bool hitable { get; set; }
    public bool has_keyboard_focus { get; set; }
    public bool selected { get; set; }
    public Dictionary<string, int> rect { get; set; }

}

namespace Permissions_UITest
{
    [TestFixture]
    public class Tests
    {
        public iOSApp app;

        [SetUp]
        public virtual void BeforeEachTest()
        {

#if ENABLE_TEST_CLOUD
                Xamarin.Calabash.Start();
#endif

            app = ConfigureApp
                .iOS
                .StartApp(Xamarin.UITest.Configuration.AppDataMode.Clear);

            app.SetOrientationPortrait();
        }

        [Test]
        public virtual void FakeNotification()
        {
            app.Screenshot("Fake Notification");
            app.WaitForElement("Bluetooth Sharing");
            app.Tap(x => x.Marked("Bluetooth Sharing"));

            Thread.Sleep(5000);
            app.DismissSpringboardAlerts();
            app.Screenshot("Fake Notification");
            app.Tap(x => x.Id("action label"));
            //app.Repl();
            app.WaitForElement("Ready for Next Alert");
        }


        [Test]
        public virtual void Location()
        {
            app.Screenshot("Location Services");
            app.WaitForElement("Location Services");
            app.Tap(x => x.Marked("Location Services"));

            Thread.Sleep(5000);
            app.Screenshot("Location Services Notification");
            app.Tap(x => x.Id("action label"));
            //app.Repl();
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }

        [Test]
        public void BackgroundLocation()
        {
            app.Screenshot("Background Location Services");
            app.WaitForElement("Background Location Services");
            app.Tap(x => x.Marked("Background Location Services"));

            Thread.Sleep(5000);
            app.Screenshot("Background Location Services Notification");
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }


        [Test]
        public void HealthKit()
        {
            app.Screenshot("Health Kit");
            app.WaitForElement("Permissions");
            app.ScrollTo("Health Kit");
            app.Tap(x => x.Marked("Health Kit"));

            Thread.Sleep(5000);
            var healthLabelQuery = new
            {
                marked = "Health Access"
            };

            var healthLabelQueryJson = app.InvokeDeviceAgentQuery(healthLabelQuery).ToString();
            System.Diagnostics.Debug.WriteLine(healthLabelQueryJson);

            var healthLabelValues = JsonConvert.DeserializeObject<Dictionary<string, List<UIElement>>>(healthLabelQueryJson);

            //bool isHealthKitAvailable = false;

            //if for some reasons there is no Health Kit screen
            if (healthLabelValues["result"].Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("Device or iOS version does not support HealthKit");
                return;
            }


            //Get the first switch info as JSON
            var switchQuery = new
            {
                type = "Switch",
                index = 0
            };

            var switchesJson = app.InvokeDeviceAgentQuery(switchQuery).ToString();
            System.Diagnostics.Debug.WriteLine(switchesJson);

            //Get the found element coordinates
            var switchesValues = JsonConvert.DeserializeObject<Dictionary<string, List<UIElement>>>(switchesJson);
            int tapX = (switchesValues["result"])[0].hit_point["x"];
            int tapY = (switchesValues["result"])[0].hit_point["y"];

            var switchCoords = new
            {
                coordinate = new
                {
                    x = tapX,
                    y = tapY
                }
            };

            //Tap on this coordinates
            app.InvokeDeviceAgentGesture("touch", specifiers: switchCoords);

            //Get the Allow button info as JSON
            var buttonsQuery = new
            {
                marked = "Allow"
            };


            var allowButtonJson = app.InvokeDeviceAgentQuery(buttonsQuery).ToString();
            System.Diagnostics.Debug.WriteLine(allowButtonJson);

            //Get the found element coordinates
            var allowButtonValues = JsonConvert.DeserializeObject<Dictionary<string, List<UIElement>>>(allowButtonJson);
            tapX = (allowButtonValues["result"])[0].hit_point["x"];
            tapY = (allowButtonValues["result"])[0].hit_point["y"];

            var allowButtonCoords = new
            {
                coordinate = new
                {
                    x = tapX,
                    y = tapY
                }
            };
            //Tap on this coordinates
            app.InvokeDeviceAgentGesture("touch", specifiers: allowButtonCoords);

            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }


        [Test]
        public void Contacts()
        {

            app.Screenshot("Contacts");
            app.WaitForElement("Contacts");
            app.Tap(x => x.Marked("Contacts"));

            Thread.Sleep(5000);
            app.Screenshot("Contacts Notification");

            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }

        [Test]
        public void Calendar()
        {

            app.Screenshot("Calendar");
            app.WaitForElement("Calendar");
            app.Tap(x => x.Marked("Calendar"));

            Thread.Sleep(5000);
            app.Screenshot("Calendar Notification");

            app.DismissSpringboardAlerts();

            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }

        [Test]
        public void Reminders()
        {

            app.Screenshot("Reminders");
            app.WaitForElement("Permissions");
            app.ScrollTo("Reminders");
            app.Tap(x => x.Marked("Reminders"));

            Thread.Sleep(5000);
            app.Screenshot("Reminders Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }


        [Test]
        public void Photos()
        {
            app.Screenshot("Photos");
            app.WaitForElement("Permissions");
            app.ScrollTo("Photos");
            app.Tap(x => x.Marked("Photos"));

            Thread.Sleep(5000);
            //for iOS 11-
            app.DismissSpringboardAlerts();
            Thread.Sleep(5000);
            //Get the Allow button info as JSON
            //TODO: Cancel word should be localized for other languages
            var buttonsQuery = new
            {
                marked = "Cancel"
            };


            var cancelButtonJson = app.InvokeDeviceAgentQuery(buttonsQuery).ToString();
            System.Diagnostics.Debug.WriteLine(cancelButtonJson);

            //Get the found element coordinates
            var allowButtonValues = JsonConvert.DeserializeObject<Dictionary<string, List<UIElement>>>(cancelButtonJson);
            int tapX = (allowButtonValues["result"])[0].hit_point["x"];
            int tapY = (allowButtonValues["result"])[0].hit_point["y"];

            var cancelButtonCoords = new
            {
                coordinate = new
                {
                    x = tapX,
                    y = tapY
                }
            };
            //Tap on this coordinates
            app.InvokeDeviceAgentGesture("touch", specifiers: cancelButtonCoords);

            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");

            //TODO:
            //Then I verify that I have access to Photos
            app.Screenshot("Notification dismissed");
        }

        [Test]
        public void Twitter()
        {

            app.Screenshot("Twitter");
            app.WaitForElement("Permissions");
            app.ScrollTo("Twitter");
            app.Tap(x => x.Marked("Twitter"));

            Thread.Sleep(5000);
            app.Screenshot("Twitter Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }

        [Test]
        public void Microphone()
        {
            app.Screenshot("Microphone");
            app.WaitForElement("Permissions");
            app.ScrollTo("Microphone");
            app.Tap(x => x.Marked("Microphone"));

            Thread.Sleep(5000);
            app.Screenshot("Microphone Notification");

            if (app.Device.IsSimulator)
            {
                //Calabash backed by DeviceAgent will not auto dismiss because it is fake
                app.WaitForElement("Microphone");
                app.Tap(x => x.Marked("OK"));
            }
            else
            {
                app.DismissSpringboardAlerts();
            }

            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }


        [Test]
        public void Motion()
        {
            app.Screenshot("Motion");
            app.WaitForElement("Permissions");
            app.ScrollTo("Motion Activity");
            app.Tap(x => x.Marked("Motion Activity"));

            Thread.Sleep(5000);
            app.Screenshot("Motion Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");

            app.Screenshot("Notification dismissed");
            //Device
            //# Requires Settings > Privacy > Motion & Fitness to be on for the alert to pop.
        }


        [Test]
        public void Camera()
        {

            app.Screenshot("Camera");
            app.WaitForElement("Permissions");
            app.ScrollTo("Camera");
            app.Tap(x => x.Marked("Camera"));

            Thread.Sleep(5000);
            app.Screenshot("Camera Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }

        [Test]
        public void APNS()
        {

            app.Screenshot("APNS");
            app.WaitForElement("Permissions");
            app.ScrollTo("APNS");
            app.Tap(x => x.Marked("APNS"));

            Thread.Sleep(5000);
            app.Screenshot("APNS Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }


        [Test]
        public void AppleMusic()
        {
            app.Screenshot("Apple Music");
            app.WaitForElement("Permissions");
            app.ScrollTo("Apple Music");
            app.Tap(x => x.Marked("Apple Music"));

            Thread.Sleep(5000);
            app.Screenshot("Apple Music Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }

        [Test]
        public void Speech()
        {
            app.Screenshot("Speech Recognition");
            app.WaitForElement("Permissions");

            //TODO: it doesn't work because scrolls to the top of the row and taps on center which is under "action label"
            //app.ScrollDownTo(c => c.Marked("Speech Recognition"));
            app.ScrollTo("Speech Recognition");
            app.Tap(c => c.Marked("Speech Recognition"));
            Thread.Sleep(5000);
            app.Screenshot("Speech Recognition Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }


        [Test]
        public void AppTrackingTransparency()
        {
            app.DismissSpringboardAlerts();
            app.Screenshot("App Tracking Transparency");
            app.WaitForElement("Permissions");

            app.ScrollTo("App Tracking Transparency");
            app.Tap(c => c.Marked("App Tracking Transparency"));
            Thread.Sleep(5000);
            app.Screenshot("App Tracking Transparency Notification");
            app.DismissSpringboardAlerts();
            app.Tap(x => x.Id("action label"));
            app.WaitForElement("Ready for Next Alert");
            app.Screenshot("Notification dismissed");
        }

    }


    class TestsRotated : Tests
    {
        [SetUp]
        public override void BeforeEachTest()
        {
            base.BeforeEachTest();
            app.SetOrientationLandscape();
        }
    }
}
