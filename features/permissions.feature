@supported
Feature: Privacy Alerts
To test apps that require protected services
I want Calabash to automatically dismiss privacy alerts

Background: The app has launched
  Given I can see the list of services requiring authorization
  And the action label says Ready for Next Alert

@location
@reset_device_settings
Scenario: Location alert is dismissed
  When I touch the Location Services row
  Then Calabash should dismiss the alert

@location
@reset_device_settings
Scenario: Background location alert is dismissed
  When I touch the Background Location Services row
  Then Calabash should dismiss the alert

@contacts
Scenario: Contacts alert is dismissed
  When I touch the Contacts row
  Then Calabash should dismiss the alert

@calendar
Scenario: Calendar alert is dismissed
  When I touch the Calendar row
  Then Calabash should dismiss the alert

@reminders
Scenario: Reminders alert is not dismissed
  When I touch the Reminders row
  Then Calabash should dismiss the alert

@photos
Scenario: Photos alert is dismissed
  When I touch the Photos row, Calabash should dismiss the alert
  Then I see the photo menu
  And I can dismiss the photo menu

@twitter
Scenario:  Twitter alert is dismissed
  When I touch the Twitter row
  Then Calabash should dismiss the alert

@bluetooth
Scenario: Bluetooth Sharing alert
  When I touch the Bluetooth Sharing row
  Then a fake bluetooth alert is generated
  And Calabash backed by UIA automatically dismisses the alert
  But Calabash backed by DeviceAgent will not auto dismiss because it is fake

@device
@microphone
Scenario: Microphone
  When I touch the Microphone row
  Then Calabash should dismiss the alert

@pending
@simulator
@microphone
Scenario: Microphone
  When I touch the Microphone row
  Then Calabash should dismiss the alert
  Then I am waiting to figure out how to generate a Microphone alert

@motion
Scenario: Motion Activity alert is dismissed
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

