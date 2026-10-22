require "application_system_test_case"

class SystemHealthTest < ApplicationSystemTestCase
  test "the browser can reach the application" do
    visit rails_health_check_path

    assert_selector "body[style='background-color: green']", visible: :all
    assert_equal "complete", page.evaluate_script("document.readyState")
  end
end
