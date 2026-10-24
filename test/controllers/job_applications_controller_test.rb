require "test_helper"

class JobApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
    @company = @user.companies.create!(name: "Acme")
    @application = JobApplication.create!(company: @company, role_title: "Rails Engineer")
  end

  test "lists applications" do
    get job_applications_url

    assert_response :success
    assert_select "a", text: "Rails Engineer"
  end

  test "company suggestions are private" do
    users(:two).companies.create!(name: "Other user's private company")

    get new_job_application_url

    assert_response :success
    assert_select "datalist option[value='Acme']"
    assert_select "datalist option[value=?]", "Other user's private company", count: 0
  end

  test "shows applications on the pipeline board" do
    get pipeline_job_applications_url

    assert_response :success
    assert_select ".pipeline-column", count: JobApplication::STATUSES.size
    assert_select ".pipeline-application", text: /Rails Engineer/
  end

  test "prefills a company when adding a role from its profile" do
    get new_job_application_url, params: { company_id: @company.id }

    assert_response :success
    assert_select "input[name='job_application[company_name]'][value='Acme']"
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

  test "filters applications by follow up timing" do
    @application.update!(status: :applied, applied_on: 2.days.ago, follow_up_on: 1.day.ago)
    JobApplication.create!(company: @company, role_title: "Later", status: :applied, applied_on: Date.current, follow_up_on: 4.days.from_now)

    get job_applications_url, params: { follow_up: "overdue" }

    assert_response :success
    assert_select ".application-row", count: 1
    assert_select ".application-title", text: "Rails Engineer"
  end

  test "sorts dated follow ups before applications without a date" do
    JobApplication.create!(company: @company, role_title: "Due soon", follow_up_on: Date.tomorrow)

    get job_applications_url, params: { sort: "follow_up" }

    assert_response :success
    assert_equal [ "Due soon", "Rails Engineer" ], css_select(".application-title").map(&:text)
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

  test "marks a follow up complete" do
    @application.update!(follow_up_on: Date.current)

    patch complete_follow_up_job_application_url(@application)

    assert_redirected_to job_application_url(@application)
    assert_nil @application.reload.follow_up_on
  end

  test "does not expose another user's application" do
    sign_out
    sign_in_as(users(:two))

    get job_application_url(@application)

    assert_response :not_found
  end
end
