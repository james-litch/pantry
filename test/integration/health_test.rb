require "test_helper"

class HealthTest < ActionDispatch::IntegrationTest
  test "the application boots and serves the health endpoint" do
    get rails_health_check_path

    assert_response :success
    assert_equal "text/html", response.media_type
  end
end
