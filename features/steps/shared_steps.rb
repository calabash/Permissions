module Permissions
  module SharedSteps

    def timeout_for_env
      if RunLoop::Environment.ci?
        30.0
      elsif RunLoop::Environment.xtc?
        10.0
      else
        6.0
      end
    end

    def animation_sleep_for_env
      if RunLoop::Environment.ci?
        5.0
      elsif RunLoop::Environment.xtc?
        3.0
      else
        1.0
      end
    end

    def alert_view_query_str
      if ios7?
        "view:'_UIModalItemAlertContentView'"
      else
        "view:'_UIAlertControllerView'"
      end
    end

    def alert_visible?(alert_title=nil)
      if alert_title.nil?
        return !query(alert_view_query_str).empty?
      end

      query = "#{alert_view_query_str} descendant label"
      results = query(query)

      results.detect do |element|
        element["text"] == alert_title
      end
    end

    def wait_for_alert
      timeout = timeout_for_env
      message = %Q[

Timed out waiting for In-App Alert after #{timeout} seconds

]
      bridge_wait_for(message, {:timeout => timeout}) do
        alert_visible?
      end
    end

    def wait_for_no_alert
      timeout = timeout_for_env
      message = %Q[

Timed out waiting for In-Alert to disappear after #{timeout} seconds

]
      bridge_wait_for(message, {:timeout => timeout}) do
        !alert_visible?
      end
    end

    def springboard_alert_visible?
      if uia_available?
        result = uia('uia.alert() != null')

        status = result["status"]

        if status != "success"
          fail("Expected `uia` to exist with 'success' but found #{status}")
        end
        result["value"]

      else
        Permissions::DeviceAgent.spring_board_alert_visible?
      end
    end

    def wait_for_springboard_alert
      timeout = timeout_for_env

      message = %Q[

Timed out waiting for Springboard Alert after #{timeout} seconds

]

      bridge_wait_for(message, {:timeout => timeout}) do
        springboard_alert_visible?
      end
    end

    def wait_for_no_springboard_alert
      timeout = timeout_for_env

      message = %Q[

Timed out waiting for Springboard Alert to disappear after #{timeout} seconds

]

      bridge_wait_for(message, {:timeout => timeout}) do
        !springboard_alert_visible?
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

When testing the Photos alert, it is possible that the animation associated with
dismissing (Cancel) the Photo Roll will cause the two_finger_tap to fail because
the touch happens on the view that is animating off - adjust the sleep.

]

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

When(/^I touch the (Contacts|Calendar|Reminders|Camera) row$/) do |row|
  expect_action_label_ready_for_next_alert
  tap_row(row.downcase)
end

When(/^I touch the Photos row$/) do
  expect_action_label_ready_for_next_alert
  tap_row("photos")
end

Then(/^I see the Photos alert$/) do
  if uia_available?
    # Impossible to wait for the alert because it is automatically dismissed
  else
    # With DeviceAgent, we can wait for the alert.  It is the next query or
    # gesture that causes the alert to be automatically dismissed.
    wait_for_springboard_alert
  end
end

Then(/^I wait for the Photo Roll to finish animating on$/) do
  # wait_for_animations will not work because the animation is outside the AUT
  sleep(animation_sleep_for_env)
end

Then(/^the Photo Roll is visible behind the alert$/) do
  # UIAutomation will dismiss the alert sometime between here and the last Step.
  wait_for_view("* marked:'Cancel'")
end

And(/^for Calabash to dismiss the Photo Alert$/) do
  # DeviceAgent will dismiss the alert by attempting to touch the Cancel button.
  if !uia_available?
    touch("* marked:'Cancel'")
  end
end

And(/^I can dismiss the Photo Roll by touching Cancel$/) do
  if uia_available?
    # Waiting for no alert does not work.
    sleep(timeout_for_env)
    touch("* marked:'Cancel'")
  else
    # DeviceAgent does not like interacting with the Photo Roll animations.
    # Sleep for a long time to make sure the final touch actually happens.
    sleep(timeout_for_env)
  end
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

When(/^I touch the Microphone row$/) do
  expect_action_label_ready_for_next_alert
  tap_row('microphone')
end

Then(/^a fake Bluetooth alert is generated$/) do
  wait_for_alert
end

Then(/^a fake Microphone alert is generated$/) do
  wait_for_alert
end

And(/^Calabash backed by UIA automatically dismisses the alert$/) do
  if uia_available?
    wait_for_animations
    wait_for_no_alert
    wait_for_alert_dismissed_text
  end
end

But(/^Calabash backed by DeviceAgent will not auto dismiss because it is fake$/) do
  if !uia_available?
    wait_for_animations
    sleep(0.4)
    touch("* marked:'OK'")
    wait_for_animations
    wait_for_no_alert
    wait_for_alert_dismissed_text
  end
end

When(/^I touch the APNS row$/) do
  tap_row("apns")
end

Then(/^an NYI alert is presented$/) do
  wait_for_alert
  expect(alert_visible?("Not Implemented")).to be_truthy
end

Then(/^a Not Supported alert is presented$/) do
  wait_for_alert
  expect(alert_visible?("Not Supported")).to be_truthy
end

Then(/^Calabash should dismiss the alert$/) do
  wait_for_springboard_alert
  wait_for_alert_dismissed_text
end

