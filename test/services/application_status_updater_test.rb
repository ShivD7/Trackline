require "test_helper"

class ApplicationStatusUpdaterTest < ActiveSupport::TestCase
  test "records a stage change when status changes" do
    application = JobApplication.create!(company: Company.create!(name: "Acme"), role_title: "Engineer")

    assert_difference -> { application.stage_changes.count }, 1 do
      assert ApplicationStatusUpdater.call(
        application: application,
        attributes: { status: "applied", applied_on: Date.current }
      )
    end

    change = application.stage_changes.last
    assert_equal "wishlist", change.from_status
    assert_equal "applied", change.to_status
  end

  test "does not record history for an invalid update" do
    application = JobApplication.create!(company: Company.create!(name: "Acme"), role_title: "Engineer")

    assert_no_difference -> { application.stage_changes.count } do
      assert_not ApplicationStatusUpdater.call(application: application, attributes: { status: "applied", applied_on: nil })
    end
  end
end
