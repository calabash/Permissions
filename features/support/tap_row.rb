module Permissions
  module TapRow

    def tap_row(id)
      query = "UITableView marked:'table'"
      options = {
        :scroll_position => :middle,
        :query => query
      }

      scroll_to_row_with_mark(id, options)
      wait_for_animations

      tap("UITableViewCell marked:'#{id}'")
    end
  end
end

World(Permissions::TapRow)

