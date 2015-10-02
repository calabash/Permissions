module Permissions
  module Alerts
    def wait_for_alert
      timeout = 4
      message = "Waited #{timeout} seconds for an alert to appear"
      wait_for(message, {:timeout => timeout}) do
        alert_exists?
      end
    end

    def wait_for_alert_with_title(alert_title)
      timeout = 4
      message = "Waited #{timeout} seconds for an alert with title '#{alert_title}' to appear"

      wait_for(message, {:timeout => timeout}) do
        alert_exists?(alert_title)
      end
    end
  end
end

