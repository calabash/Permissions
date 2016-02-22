@health_kit
Feature: Health Kit Permissions
In order to make testing Health Kit interactions easier
As a developer
I want an example of Calabash dismissng a Health Kit dialog

@wip
Scenario: Health Kit privacy alerts can be dismissed, but not automatically
  Given I can see the list of services requiring authorization
  When I touch the Health Kit row
  Then I see the HealthKit modal view or Not Supported alert
  And Calabash should enable all categories and allow

