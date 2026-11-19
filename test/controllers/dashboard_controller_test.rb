require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "renders the dashboard" do
    get root_url

    assert_response :success
    assert_select "h1", /Good/
    assert_select ".metric-card", count: 5
    assert_select ".metric-card", text: /Moves this week/
  end

  test "groups active follow ups by date" do
    company = @user.companies.create!(name: "Acme")
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

  test "dashboard prioritizes overdue follow ups and excludes closed and private applications" do
    company = @user.companies.create!(name: "Attention")
    JobApplication.create!(company:, role_title: "Overdue role", status: :applied, applied_on: 5.days.ago, follow_up_on: 2.days.ago)
    JobApplication.create!(company:, role_title: "Today role", status: :applied, applied_on: 3.days.ago, follow_up_on: Date.current)
    JobApplication.create!(company:, role_title: "Closed role", status: :rejected, applied_on: 3.days.ago, follow_up_on: 1.day.ago)
    private_company = users(:two).companies.create!(name: "Private attention")
    JobApplication.create!(company: private_company, role_title: "Private role", status: :applied, applied_on: 4.days.ago, follow_up_on: 3.days.ago)

    get root_url

    assert_response :success
    assert_select ".attention-card .follow-up-item small", text: "Overdue role"
    assert_equal [ "Overdue role", "Today role" ], css_select(".attention-card .follow-up-item small").map(&:text)
    assert_select ".attention-card", text: /Overdue ·/
    assert_select ".attention-card", text: /You’re all caught up/, count: 0
  end

  test "weekly activity uses applied dates and only the signed-in user's applications" do
    travel_to Time.zone.local(2026, 11, 19, 12) do
      company = @user.companies.create!(name: "Activity")
      JobApplication.create!(company:, role_title: "This week", status: :applied, applied_on: Date.current)
      JobApplication.create!(company:, role_title: "Last week", status: :applied, applied_on: 1.week.ago.to_date)
      JobApplication.create!(company:, role_title: "Old role", status: :applied, applied_on: 8.weeks.ago.to_date)
      JobApplication.create!(company:, role_title: "Wishlist")
      private_company = users(:two).companies.create!(name: "Private activity")
      JobApplication.create!(company: private_company, role_title: "Private role", status: :applied, applied_on: Date.current)

      get root_url

      assert_response :success
      assert_equal [ "0", "0", "1", "1" ], css_select(".activity-row strong").map { |element| element.children.first.text }
    end
  end


  test "dashboard metrics only include the signed-in user's data" do
    own_company = @user.companies.create!(name: "Mine")
    JobApplication.create!(company: own_company, role_title: "Visible")
    other_company = users(:two).companies.create!(name: "Private")
    JobApplication.create!(company: other_company, role_title: "Hidden")

    get root_url

    assert_response :success
    assert_select ".application-title", text: "Visible"
    assert_select ".application-title", text: "Hidden", count: 0
  end
end
