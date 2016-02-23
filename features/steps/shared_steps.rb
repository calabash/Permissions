
Given(/^I can see the list of services requiring authorization$/) do
  wait_for_view("view marked:'table'")

  if query("view marked:'page'", :isHealthKitAvailable).first == 1
    @supports_health_kit = true
  else
    @supports_health_kit = false
  end
end

When(/^I touch the (Contacts|Calendar|Reminders|Photos|Camera|Microphone) row$/) do |row|
  tap_row(row.downcase)
end

When(/^I touch the (Facebook|Twitter) row$/) do |row|
  tap_row(row.downcase)
end

When(/^I touch the (Home|Health) Kit row$/) do |row|
  tap_row("#{row.downcase} kit")
end

When(/^I touch the Location Services row$/) do
  tap_row('location')
end

When(/^I touch the Background Location Services row$/) do
  tap_row('background location')
end

When(/^I touch the Motion Activity row$/) do
  tap_row('motion')
end

When(/^I touch the Bluetooth Sharing row$/) do
  tap_row('bluetooth')
end

And(/^I see the photo roll$/) do
  wait_for_view("view marked:'Photos'")
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

Then(/^I see the HealthKit modal view or Not Supported alert$/) do
  if @supports_health_kit
    wait_for_none_animating
  else
    begin
      title = alert_title
    rescue => e
      raise "Expected this device to support health kit: #{@supports_health_kit}\n#{e}"
    end
    expect(title).to be == "Not Supported"
    button_title = leftmost_button_title
    tap_alert_button(button_title)
  end
end

Then(/^I can enable HealthKit permissions and dismiss the page$/) do
  if @supports_health_kit
    if RunLoop::Environment.ci?
      pause = 10.0
    elsif RunLoop::Environment.xtc?
      pause = 8.0
    else
      pause = 3.0
    end

    if ios8?
      ["Body Mass Index", "Height", "Weight",
       "Date of Birth", "Sex", "Steps"].each do |mark|
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
    # nop - device or iOS does not support health kit
    puts "   Device or iOS version does not support HealthKit"
  end

  message = "Expected Health Access permissions view to disappear"
  wait_for(message) do
    uia_query(:view, {marked:"Health Access"}).empty?
  end

  wait_for_view("view marked:'page'")
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
  # In a previous implementation, I was able to demonstrate that the first
  # UIA query after the `onAlert()` call will _time out_, regardless of
  # whether or not the alert is dismissed.
  # https://github.com/calabash/calabash/issues/277
  # Calabash::Device.default.send(:uia_serialize_and_call, :query, 'window')

  # If a Privacy Alert is showing, all UIAutomation traffic is blocked.
  # query will still work because it does not interact with UIAutomation.
  #
  # If the UIA call times out, then there is probably a privacy alert.
  if RunLoop::Environment.ci?
    timeout = 15.0
  elsif RunLoop::Environment.xtc?
    timeout = 8.0
  else
    timeout = 3.0
  end

  message = "Timed out after #{timeout} seconds waiting for alert to be dismissed"
  with_timeout(timeout, message) { uia_with_app('alert()') }
end

