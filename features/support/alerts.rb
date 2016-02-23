module Permissions
  module Alerts

    def alert_exists?(alert_title=nil)
      if alert_title.nil?
        res = uia('uia.alert() != null')
      else
        if ios6?
          res = uia("uia.alert().staticTexts()['#{alert_title}'].label()")
        else
          res = uia("uia.alert().name() == '#{alert_title}'")
        end
      end

      if !res.is_a?(Hash)
        fail("Expected `uia` to return a Hash but found #{res}")
      end

      status = res["status"]

      if status != "success"
        fail("Expected `uia` to exist with 'success' but found #{status}")
      end

      res["value"]
    end

    def alert_button_exists?(button_title)
      unless alert_exists?
        fail('Expected an alert to be showing')
      end

      res = uia("uia.alert().buttons()['#{button_title}']")

      if res.empty?
        false
      else
        res.first
      end
    end

    def tap_alert_button(button_title)
      wait_for_alert

      uia("uia.alert().buttons()['#{button_title}'].tap()")
    end

    def alert_view_query_str
      if ios8? || ios9?
        "view:'_UIAlertControllerView'"
      elsif ios7?
        "view:'_UIModalItemAlertContentView'"
      else
        'UIAlertView'
      end
    end

    def button_views
      wait_for_alert

      if ios8? || ios9?
        query = "view:'_UIAlertControllerActionView'"
      elsif ios7?
        query = "view:'_UIModalItemAlertContentView' descendant UITableView descendant label"
      else
        query = 'UIAlertView descendant button'
      end
      query(query)
    end

    def button_titles
      button_views.map { |res| res['label'] }.compact
    end

    def leftmost_button_title
      with_min_x = button_views.min_by do |res|
        res['rect']['x']
      end
      with_min_x['label']
    end

    def rightmost_button_title
      with_max_x = button_views.max_by do |res|
        res['rect']['x']
      end
      with_max_x['label']
    end

    def all_labels
      wait_for_alert
      query = "#{alert_view_query_str} descendant label"
      query(query)
    end

    def non_button_views
      button_titles = button_titles()
      all_labels = all_labels()
      all_labels.select do |res|
        !button_titles.include?(res['label']) &&
              res['label'] != nil
      end
    end

    def alert_message
      with_max_y = non_button_views.max_by do |res|
        res['rect']['y']
      end

      with_max_y['label']
    end

    def alert_title
      with_min_y = non_button_views.min_by do |res|
        res['rect']['y']
      end
      with_min_y['label']
    end
  end
end

World(Permissions::Alerts)

