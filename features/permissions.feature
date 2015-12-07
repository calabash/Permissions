Feature: Privacy Alerts
  In order to make testing app that require protected services easier
  As a developer
  I want Calabash to automatically dismiss privacy alerts

Background: The app has launched
  Given I can see the list of services requiring authorization

@location
@reset_device_settings
Scenario: Location alert is dismissed
  When I touch the Location Services row
  Then Calabash should dismiss the alert

@reset_device_settings
@location
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
  When I touch the Photos row
  Then Calabash should dismiss the alert
  And I see the photo roll

@bluetooth
Scenario: Bluetooth Sharing alert
  When I touch the Bluetooth Sharing row
  Then Calabash should dismiss the alert

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

