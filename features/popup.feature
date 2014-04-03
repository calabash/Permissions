Feature: Getting permission pop-ups
  I want to get all the pop-ups available for
  iOS 7.0 and greater. And whenever they
  appear take a picture.

Scenario: Location Steps 
  Given I am on the Welcome Screen
  Then I should see a "Location Services" button
  And take picture
  Then I touch the "Location Services" button
  And take picture

Scenario: Bluetooth
	Given I am on the Welcome Screen
	Then I should see a "Bluetooth Sharing" button
	Then I touch the "Bluetooth Sharing" button
	And take picture
