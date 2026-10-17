require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "renders the dashboard" do
    get root_url

    assert_response :success
    assert_select "h1", /Good/
    assert_select ".metric-card", count: 4
  end
end
