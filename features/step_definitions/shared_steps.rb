module Permissions
  module SharedSteps

    def tap_row(id)
      query = "UITableView marked:'table'"
      options = { :scroll_position => :middle }

      scroll_to_row_with_mark(query, id, options)

      tap("UITableViewCell marked:'#{id}'")
    end
  end
end

World(Permissions::SharedSteps)

Given(/^I can see the list of services requiring authorization$/) do
  wait_for_view("view marked:'table'")
end

When(/^I touch the (Facebook|Contacts) row$/) do |row|
  tap_row(row.downcase)
end

When(/^I touch the (Home|Health) Kit row$/) do |row|
  tap_row("#{row.downcase} kit")
end

When(/^I touch the Location Services row$/) do
  tap_row('location')
end

