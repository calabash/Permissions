@supported
Feature: Privacy Alerts
To test apps that require protected services
I want Calabash to automatically dismiss privacy alerts

Background: The app has launched
And I can see the list of services requiring authorization
Given I rotate the device so the home button is on the bottom
And the action label says Ready for Next Alert

@location
@reset_device_settings
Scenario: Location alert is dismissed
When I touch the Location Services row
Then Calabash should dismiss the alert
And location services are authorized

@location
@reset_device_settings
Scenario: Background location alert is dismissed
When I touch the Background Location Services row
Then Calabash should dismiss the alert
And background location services are authorized

@skip_for_non_english
@health_kit
@reset_device_settings
Scenario: Enabling Health Kit permissions
When I touch the Health Kit row
Then I see the HealthKit modal view or Not Supported alert
Then I can enable HealthKit permissions and dismiss the page

@contacts
Scenario: Contacts alert is dismissed
When I touch the Contacts row
Then Calabash should dismiss the alert
And access to contacts is authorized

@calendar
Scenario: Calendar alert is dismissed
When I touch the Calendar row
Then Calabash should dismiss the alert
And access to calendar is authorized

@reminders
Scenario: Reminders alert is not dismissed
When I touch the Reminders row
Then Calabash should dismiss the alert
And access to reminders is authorized

@skip_for_non_english
@photos
Scenario: Photos alert is dismissed
When I touch the Photos row
Then I see the Photos alert
Then I wait for the Photo Roll to finish animating on
And for Calabash to dismiss the Photo Alert
And I can dismiss the Photo Roll by touching Cancel
Then I verify that I have access to Photos

@twitter
Scenario:  Twitter alert is dismissed
When I touch the Twitter row
Then Calabash should dismiss the alert

#@bluetooth
#Scenario: Bluetooth Sharing alert
# Flickering.
# https://jira.xamarin.com/browse/TCFW-588
#When I touch the Bluetooth Sharing row
#Then a fake Bluetooth alert is generated
#And Calabash backed by UIA automatically dismisses the alert
#But Calabash backed by DeviceAgent will not auto dismiss because it is fake

@device
@microphone
Scenario: Microphone on Device
When I touch the Microphone row
Then Calabash should dismiss the alert

@simulator
@microphone
Scenario: Microphone on Simulator
When I touch the Microphone row
Then a fake Microphone alert is generated
And Calabash backed by UIA automatically dismisses the alert
But Calabash backed by DeviceAgent will not auto dismiss because it is fake

@simulator
@motion
Scenario: Motion Activity on Simulator
When I touch the Motion Activity row
Then Calabash should dismiss the alert

# Requires Settings > Privacy > Motion & Fitness to be on for the alert to pop.
@device
@motion
Scenario: Motion Activity on Device
When I touch the Motion Activity row
Then Calabash should dismiss the alert

@camera
Scenario: Camera alert is not dismissed
When I touch the Camera row
Then Calabash should dismiss the alert

@apns
Scenario: Apple Push Notification Services
When I touch the APNS row
Then Calabash should dismiss the alert

@music
Scenario: Apple Music on Simulator
When I touch the Apple Music row
Then Calabash should dismiss the alert

@speech
Scenario: Speech Recognition on Simulator
When I touch the Speech Recognition row
Then Calabash should dismiss the alert

#@all_alerts
#@not_xtc
#@reset_device_settings
#https://jira.xamarin.com/browse/TCFW-589
#Scenario: 999 Dismiss all alerts
#Then the app pops all the alerts
#Then I make a query to trigger the alerts to be dismissed
#Then all the alerts have been dismissed
