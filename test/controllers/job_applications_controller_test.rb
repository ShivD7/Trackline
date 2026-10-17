require "test_helper"

class JobApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "Acme")
    @application = JobApplication.create!(company: @company, role_title: "Rails Engineer")
  end

  test "lists applications" do
    get job_applications_url

    assert_response :success
    assert_select "a", text: "Rails Engineer"
  end

  test "shows applications on the pipeline board" do
    get pipeline_job_applications_url

    assert_response :success
    assert_select ".pipeline-column", count: JobApplication::STATUSES.size
    assert_select ".pipeline-application", text: /Rails Engineer/
  end

  test "creates an application and its initial history" do
    assert_difference [ "JobApplication.count", "Company.count", "StageChange.count" ], 1 do
      post job_applications_url, params: {
        job_application: {
          company_name: "Northstar", role_title: "Developer", status: "applied",
          priority: "high", applied_on: Date.current
        }
      }
    end

    assert_redirected_to job_application_url(JobApplication.order(:created_at).last)
  end

  test "filters applications by search" do
    get job_applications_url, params: { q: "Acme" }

    assert_response :success
    assert_select ".application-row", count: 1
  end

  test "updates status through the history service" do
    assert_difference -> { @application.stage_changes.count }, 1 do
      patch job_application_url(@application), params: {
        job_application: {
          company_name: "Acme", role_title: @application.role_title,
          status: "screening", priority: "medium", applied_on: Date.current
        }
      }
    end

    assert_redirected_to job_application_url(@application)
    assert_equal "screening", @application.reload.status
  end

  test "duplicates an application as a fresh wishlist item" do
    @application.update!(status: :applied, applied_on: Date.current, follow_up_on: 3.days.from_now)

    assert_difference [ "JobApplication.count", "StageChange.count" ], 1 do
      post duplicate_job_application_url(@application)
    end

    copy = JobApplication.order(:created_at).last
    assert_redirected_to edit_job_application_url(copy)
    assert_equal "wishlist", copy.status
    assert_nil copy.applied_on
    assert_nil copy.follow_up_on
    assert_equal @application.company, copy.company
  end
end
