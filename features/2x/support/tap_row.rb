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

