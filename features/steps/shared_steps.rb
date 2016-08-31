module Permissions
  module SharedSteps

    def timeout_for_env
      if RunLoop::Environment.ci?
        30.0
      elsif RunLoop::Environment.xtc?
        8.0
      else
        3.0
      end
    end

    def expect_action_label_ready_for_next_alert
      query = "* marked:'action label'"
      wait_for_view(query)

      timeout = timeout_for_env

      message = %Q[
Timed out after #{timeout} seconds waiting for text in action label to be:

  'Ready for Next Alert'

with query:

  #{query}

Something is blocking the touch gesture.

]

      # Change the label text to 'Ready for Next Alert'.  If the alert has been
      # dismissed, the text will change.  If the alert has not been dismissed
      # the gesture will fail silently.
      touch(query)

      # Wait.
      bridge_wait_for(message, {:timeout => timeout}) do
        query(query)[0]["text"] == "Ready for Next Alert"
      end
    end

    def wait_for_alert_dismissed_text
      query = "* marked:'action label'"
      wait_for_view(query)

      timeout = timeout_for_env

      message = %Q[
Timed out after #{timeout} seconds waiting for text in action label to be:

  'Alert Dismissed'

with query:

  #{query}

This means that there is an alert blocking Calabash gestures and that Calabash
failed to auto dismiss the alert.

]

      sleep(timeout)

      # Change the label text to 'Alert Dismissed'.  If the alert has been
      # dismissed, the text will change.  If the alert has not been dismissed
      # the gesture will fail silently.
      two_finger_tap(query)

      bridge_wait_for(message, {:timeout => timeout}) do
        query(query)[0]["text"] == "Alert Dismissed"
      end
    end
  end
end

World(Permissions::SharedSteps)

Given(/^I can see the list of services requiring authorization$/) do
  wait_for_view("view marked:'table'")

  if query("view marked:'page'", :isHealthKitAvailable).first == 1
    @supports_health_kit = true
  else
    @supports_health_kit = false
  end
end

And(/^the action label says Ready for Next Alert$/) do
  expect_action_label_ready_for_next_alert
end

When(/^I touch the (Contacts|Calendar|Reminders|Camera|Microphone) row$/) do |row|
  expect_action_label_ready_for_next_alert
  tap_row(row.downcase)
end

When(/^I touch the Photos row, Calabash should dismiss the alert$/) do
  expect_action_label_ready_for_next_alert
  tap_row("photos")
end

Then(/^I see the photo menu$/) do

  if uia_available?
    timeout = timeout_for_env
    message = %Q[

Waited for #{timeout} seconds for alert to disappear.  Calabash did not dismiss
the alert automatically.

]

    bridge_wait_for(message, {:timeout => timeout}) do
      !alert_exists?
    end
  else
    # Photo roll takes time to fully animate on and without an interface to
    # device agent queries, all we can do is hard wait.
    sleep(5.0)
  end

  wait_for_view("* marked:'Cancel'")
end

And(/^I can dismiss the photo menu$/) do
  wait_for_animations
  touch("* marked:'Cancel'")
  wait_for_animations

  wait_for_alert_dismissed_text
end

When(/^I touch the (Facebook|Twitter) row$/) do |row|
  expect_action_label_ready_for_next_alert
  tap_row(row.downcase)
end

When(/^I touch the (Home|Health) Kit row$/) do |row|
  expect_action_label_ready_for_next_alert
  tap_row("#{row.downcase} kit")
end

When(/^I touch the Location Services row$/) do
  expect_action_label_ready_for_next_alert
  tap_row('location')
end

When(/^I touch the Background Location Services row$/) do
  expect_action_label_ready_for_next_alert
  tap_row('background location')
end

When(/^I touch the Motion Activity row$/) do
  expect_action_label_ready_for_next_alert
  tap_row('motion')
end

When(/^I touch the Bluetooth Sharing row$/) do
  expect_action_label_ready_for_next_alert
  tap_row('bluetooth')
end

Then(/^a fake bluetooth alert is generated$/) do
   wait_for_alert
end

And(/^Calabash backed by UIA automatically dismisses the alert$/) do
  if uia_available?
    wait_for_alert_dismissed_text
  end
end

But(/^Calabash backed by DeviceAgent will not auto dismiss because it is fake$/) do
  if !uia_available?
    wait_for_animations
    sleep(2.0)
    touch("* marked:'OK'")
    wait_for_alert_dismissed_text
  end
end

Then(/^I am waiting to figure out how to generate a Microphone alert$/) do
  message = "Cannot reliably generate a 'Microphone' alert yet. :("
  pending(message)
end

When(/^I touch the APNS row$/) do
  tap_row("apns")
end

Then(/^an NYI alert is presented$/) do
  expect(alert_title).to be == 'Not Implemented'
end

Then(/^a Not Supported alert is presented$/) do
  expect(alert_title).to be == "Not Supported"
end

Then(/^Calabash does not dismiss the alert$/) do
  # See the comments below.
  begin
    with_timeout(3.0, 'Ignored') { uia_with_app('alert()') }
    fail("Expected a Privacy Alert to be showing. Such alerts block UIA traffic")
  rescue Calabash::IOS::RouteError => _
  end
end

Then(/^Calabash should dismiss the alert$/) do
  wait_for_alert_dismissed_text
end

