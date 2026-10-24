require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "normal database preparation preserves existing accounts and records" do
    company = users(:one).companies.create!(name: "Keep me")
    application = company.job_applications.create!(role_title: "My application")

    assert_no_difference [ "User.count", "Company.count", "JobApplication.count" ] do
      capture_io { load Rails.root.join("db/seeds.rb") }
    end

    assert_equal "My application", application.reload.role_title
  end
end
