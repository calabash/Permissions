Feature: Privacy Alerts: orientations
To test apps that require protected services
I want Calabash to automatically dismiss privacy alerts in every orientation

@reset_device_settings
@orientation
Scenario Outline: Alerts in non-portrait orientation
Given I can see the list of services requiring authorization
Given I rotate the device so the home button is on the <position>
And the action label says Ready for Next Alert
When I touch the Location Services row
Then Calabash should dismiss the alert
And location services are authorized
When I touch the Contacts row
Then Calabash should dismiss the alert
And access to contacts is authorized
When I touch the Reminders row
Then Calabash should dismiss the alert
And access to reminders is authorized

Examples:
| position |
| right    |
| left     |
| top      |
