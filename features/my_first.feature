Feature: Running a test
  As an iOS developer
  I want to have a sample feature file
  So I can begin testing quickly

Scenario: Location Steps 
  Given I am on the Welcome Screen
  Then I should see a "Location Services" button
  And take picture
  Then I touch the "Locations Services" button
  And take picture

	Scenario: Contacts
		Given I am on the Welcome Screen
		Then I should see a "Contacts" button
		And take picture

	Scenario: Bluetooth
		Given I am on the Welcome Screen
		Then I should see a "Bluetooth Sharing" button
		Then I touch "Bluetooth Sharing" button
		And take picture
