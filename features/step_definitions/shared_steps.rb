
Given(/^I can see the list of services requiring authorization$/) do
  wait_for_view("view marked:'table'")
end

When(/^I touch the Facebook row$/) do
  query = "UITableView marked:'table'"
  options = { :scroll_position => :middle }
  scroll_to_row_with_mark(query, 'facebook', options)

  tap("UITableViewCell marked:'facebook'")
end

