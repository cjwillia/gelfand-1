module ApplicationHelper
    def bg_check_button_class bg_check, status
        bg_check.status==status ? "button small disabled": "button small"
    end
end
