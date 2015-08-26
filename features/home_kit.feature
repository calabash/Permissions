@home_kit
Feature: Home Kit Permissions
In order to make testing Home Kit interactions easier
As a developer
I want Calabash to automatically dismiss Home Kit alerts

Scenario: Home Kit privacy alerts are not handled yet
  Given I can see the list of services requiring authorization
  When I touch the Home Kit row
  Then an NYI alert is presented

