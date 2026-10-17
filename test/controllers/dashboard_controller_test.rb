require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "renders the dashboard" do
    get root_url

    assert_response :success
    assert_select "h1", /Good/
    assert_select ".metric-card", count: 5
    assert_select ".metric-card", text: /Moves this week/
  end

  test "groups active follow ups by date" do
    company = Company.create!(name: "Acme")
    JobApplication.create!(company:, role_title: "Past", status: :applied, applied_on: 3.days.ago, follow_up_on: 1.day.ago)
    JobApplication.create!(company:, role_title: "Today", status: :screening, applied_on: 2.days.ago, follow_up_on: Date.current)
    JobApplication.create!(company:, role_title: "Future", status: :interviewing, applied_on: 1.day.ago, follow_up_on: 3.days.from_now)

    get follow_ups_url

    assert_response :success
    assert_select ".follow-up-section", count: 3
    assert_select ".application-title", text: "Past"
    assert_select ".application-title", text: "Today"
    assert_select ".application-title", text: "Future"
  end
end
