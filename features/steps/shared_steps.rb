module Permissions
  module SharedSteps

    SERVICES_WITH_BACKDOOR_CHECKS = [
      "location", "background location", "contacts", "calendar", "reminders"
    ]

    def service_authorized?(service_name)
      backdoor("isServiceAuthorized:", service_name)
    end

    def wait_for_service_authorized(service_name)
      if !SERVICES_WITH_BACKDOOR_CHECKS.include?(service_name)
        raise "Service '#{service_name}' does not have a backdoor status check"
      end

      timeout = timeout_for_env
      message = %Q[

Timed out waiting for #{service_name} to be authorized after #{timeout} seconds.

]
      bridge_wait_for(message, {:timeout => timeout}) do
        service_authorized?(service_name)
      end
    end

    def tap_row(id)
      query = "UITableView marked:'table'"
      options = {
        :scroll_position => :middle,
        :query => query
      }

      scroll_to_row_with_mark(id, options)
      wait_for_animations

      touch("UITableViewCell marked:'#{id}'")
      sleep(animation_sleep_for_env)
    end

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

Timed out waiting for In-App Alert to disappear after #{timeout} seconds

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
        device_agent.springboard_alert_visible?
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

And(/^I rotate the device so the home button is on the (top|bottom|left|right)$/) do |position|
  wait_for_animations
  sleep(1.0)
  rotate_home_button_to(position.to_s)
  sleep(1.0)
  wait_for_animations
end

When(/^I touch the Photos row$/) do
  expect_action_label_ready_for_next_alert
  tap_row("photos")
end

Then(/^I see the Photos alert$/) do
  if uia_available?
    # Impossible to wait for the alert because it is automatically dismissed
  else
    if ios_gte_11?
      # Surprise!  No alert for Photos in iOS 11.
    else
      # With DeviceAgent, we can wait for the alert.  It is the next query or
      # gesture that causes the alert to be automatically dismissed.
      wait_for_springboard_alert
    end
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
    sleep(timeout_for_env)
  else
    # DeviceAgent does not like interacting with the Photo Roll animations.
    # Sleep for a long time to make sure the final touch actually happens.
    sleep(timeout_for_env)
  end
  if ios_gte_11?
    # Surprise!  There is no Photos alert in iOS 11
  else
    wait_for_alert_dismissed_text
  end
end

Then(/^I see the Photo Roll$/) do
  wait_for_view("* marked:'Cancel'")
end

Then(/^I verify that I have access to Photos$/) do
  expect_action_label_ready_for_next_alert
  tap_row("photos")
  wait_for_view("* marked:'Cancel'")

  if !uia_available?
    query = "* {text CONTAINS 'does not have access' }"
    if !query(query).empty?
      fail("Expected to see the photo roll")
    end
  end

  sleep(timeout_for_env)

  touch("* marked:'Cancel'")
  wait_for_view("* marked:'action label'")
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

When(/^I touch the Apple Music row$/) do
  tap_row("apple music")
end

When(/^I touch the Speech Recognition row$/) do
  tap_row("speech recognition")
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
  # If the alert is dismissed too fast, then waiting will timeout.
  # There is no way to reliably wait for a SpringBoard alert.
  # The automatic dismiss is async in both cases.
  if uia_available?
    sleep(timeout_for_env)
  else
    # The query causes the alert to be dismissed.
    query("*")
  end

  # We can wait for no spring board alerts.
  wait_for_no_springboard_alert
  wait_for_alert_dismissed_text
end

Then(/^I see the HealthKit modal view or Not Supported alert$/) do
  if @supports_health_kit
    message = "Expected Health Access permissions view to appear"
    bridge_wait_for(message) do
      if uia_available?
        !uia_query(:view, {marked:"Health Access"}).empty?
      else
        !device_agent.query({marked: "Health Access"}).empty?
      end
    end
    wait_for_none_animating
  else
    wait_for_alert
    wait_for_none_animating
    sleep(1.0)
    touch("* marked:'Dismiss'")
    wait_for_no_alert
  end
end

Then(/^I can enable HealthKit permissions and dismiss the page$/) do
  if !@supports_health_kit
    # nop - device or iOS does not support health kit
    puts "   Device or iOS version does not support HealthKit"

  else
    if RunLoop::Environment.ci?
      pause = 10.0
    elsif RunLoop::Environment.xtc?
      pause = 8.0
    else
      pause = 3.0
    end

    if uia_available?
      if ios8?
        # Just enable some rows.  What is visible depends on iOS version
        # and form factor.
        ["Body Mass Index", "Height", "Weight"].each do |mark|

          uia_call(:tableView, {:scrollToElementWithName => mark})
          sleep(pause)
          uia_call([:switch, {:marked => mark}], {:setValue => true})
          sleep(pause)
        end

        uia_tap_mark("Done")
      else
        sleep(pause)
        uia_tap_mark("All Categories On")
        sleep(pause)
        uia_tap_mark("Allow")
      end
    else
      sleep(pause)
      device_agent.touch({marked: "Turn All Categories On"})
      sleep(pause)
      device_agent.touch({marked: "Allow"})

      # Remove when the Cannot wait for "Health Access" view to disappear
      # issue is resolved.
      # https://jira.xamarin.com/browse/TCFW-584
      sleep(pause)
    end

    timeout = timeout_for_env
    message = %Q[

Waited for #{timeout} seconds for the Health Access permissions view to disappear

]
    bridge_wait_for(message, {:timeout => timeout} ) do
      if uia_available?
        uia_query(:view, {marked:"Health Access"}).empty?
      else
        # https://jira.xamarin.com/browse/TCFW-584
        # Cannot wait for the "Health Access" view to disappear.
        # device_agent.query({text: "Health Access"}).empty?
        true
      end
    end

    wait_for_view("view marked:'page'")
  end
end

And(/^(location|background location) services are authorized$/) do |service|
  wait_for_service_authorized(service)
end

And(/^access to (reminders|calendar|contacts) is authorized$/) do |service|
  wait_for_service_authorized(service)
end

Then(/^the app pops all the alerts$/) do
  query("* marked:'page'", :sendNotificationToPresentAllAlerts)
end

Then(/^I make a query to trigger the alerts to be dismissed$/) do
  begin
    query("*")
  rescue => e
    puts "timeout: #{e}"
  end
end

Then(/^all the alerts have been dismissed$/) do
  wait_for_alert_dismissed_text
end
