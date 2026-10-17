require "test_helper"

class JobApplicationTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(name: "Acme")
  end

  test "requires an applied date after leaving the wishlist" do
    application = JobApplication.new(company: @company, role_title: "Engineer", status: :applied)

    assert_not application.valid?
    assert_includes application.errors[:applied_on], "is required once an application leaves the wishlist"
  end

  test "search matches company, role, and location" do
    toronto = JobApplication.create!(company: @company, role_title: "Platform Engineer", location: "Toronto")
    other = JobApplication.create!(company: Company.create!(name: "Elsewhere"), role_title: "Designer", location: "Montreal")

    assert_equal [ toronto ], JobApplication.search("platform")
    assert_equal [ toronto ], JobApplication.search("acme")
    assert_equal [ other ], JobApplication.search("Montreal")
  end

  test "detects overdue active follow ups" do
    application = JobApplication.create!(company: @company, role_title: "Engineer", status: :screening, applied_on: 3.days.ago, follow_up_on: 1.day.ago)

    assert application.overdue?
    assert_includes JobApplication.follow_up_due, application
  end

  test "terminal applications are not overdue" do
    application = JobApplication.create!(company: @company, role_title: "Engineer", status: :rejected, applied_on: 3.days.ago, follow_up_on: 1.day.ago)

    assert_not application.overdue?
  end

  test "detects active applications that have gone stale" do
    application = JobApplication.create!(company: @company, role_title: "Engineer", status: :applied, applied_on: 20.days.ago)
    application.update_column(:updated_at, 15.days.ago)

    assert application.stale?
    assert_includes JobApplication.stale, application

    application.update!(status: :rejected)
    assert_not application.stale?
  end
end
