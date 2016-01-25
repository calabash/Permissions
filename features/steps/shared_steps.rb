
Given(/^I can see the list of services requiring authorization$/) do
  wait_for_view("view marked:'table'")
end

When(/^I touch the (Facebook|Contacts|Calendar|Reminders|Photos|Camera|Microphone) row$/) do |row|
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

