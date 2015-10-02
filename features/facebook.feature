@facebook
Feature: Facebook Permissions
In order to make testing Facebook interactions easier
As a developer
I want Calabash to automatically dismiss Facebook alerts

@not_xtc
Scenario: Facebook privacy alerts are not handled yet
  Given I can see the list of services requiring authorization
  When I touch the Facebook row
  Then an NYI alert is presented

