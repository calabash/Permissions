
Then(/^I see the HealthKit modal view or Not Supported alert$/) do
  if @supports_health_kit
    message = "Expected Health Access permissions view to appear"
    bridge_wait_for(message) do
      !uia_query(:view, {marked:"Health Access"}).empty?
    end
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
      # Skip the 'Sex' row because the text varies across simulator,
      # physical devices, and form factors - the 6 plus has: Biological Sex
      ["Body Mass Index", "Height", "Weight",
       "Date of Birth", "Steps"].each do |mark|

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
  bridge_wait_for(message) do
    uia_query(:view, {marked:"Health Access"}).empty?
  end

  wait_for_view("view marked:'page'")
end

