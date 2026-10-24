require "test_helper"

class PrivateAccountsTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @company = @owner.companies.create!(name: "Private employer")
    @application = @company.job_applications.create!(role_title: "Private role", status: :applied, applied_on: Date.current, follow_up_on: Date.current)
    @note = @application.notes.create!(body: "Private note", occurred_on: Date.current)
    sign_in_as(users(:two))
  end

  test "all application mutations reject another user's records" do
    assert_no_difference [ "JobApplication.count", "Company.count", "Note.count", "StageChange.count" ] do
      patch job_application_path(@application), params: { job_application: { role_title: "Changed", company_name: "Hijacked" } }
      assert_response :not_found
      post duplicate_job_application_path(@application)
      assert_response :not_found
      patch complete_follow_up_job_application_path(@application)
      assert_response :not_found
      delete job_application_path(@application)
      assert_response :not_found
      post job_application_notes_path(@application), params: { note: { body: "Changed", occurred_on: Date.current } }
      assert_response :not_found
      delete job_application_note_path(@application, @note)
      assert_response :not_found
    end
    assert_equal "Private role", @application.reload.role_title
    assert_equal Date.current, @application.follow_up_on
  end

  test "company mutations reject another user's records" do
    patch company_path(@company), params: { company: { name: "Changed" } }
    assert_response :not_found
    delete company_path(@company)
    assert_response :not_found
    assert_equal "Private employer", @company.reload.name
  end

  test "all listing pages and form suggestions exclude private records" do
    [ root_path, job_applications_path, pipeline_job_applications_path, follow_ups_path, companies_path, new_job_application_path ].each do |path|
      get path
      assert_response :success
      assert_not_includes response.body, "Private employer", path
      assert_not_includes response.body, "Private role", path
    end
  end
end
