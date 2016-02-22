@health_kit
Feature: Health Kit Permissions
In order to make testing Health Kit interactions easier
As a developer
I want Calabash to automatically dismiss Health Kit alerts

@not_xtc
@wip
Scenario: Health Kit privacy alerts are not handled yet
  Given I can see the list of services requiring authorization
  When I touch the Health Kit row
  Then a Not Supported alert is presented
