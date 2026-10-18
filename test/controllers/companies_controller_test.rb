require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
    @northstar = @user.companies.create!(name: "Northstar", industry: "Fintech", headquarters: "Toronto")
    @user.companies.create!(name: "Bluebird", industry: "Healthcare", headquarters: "Montreal")
  end

  test "searches companies by profile details" do
    get companies_url, params: { q: "Toronto" }

    assert_response :success
    assert_select ".company-card", count: 1
    assert_select ".company-card h2", text: "Northstar"
  end

  test "does not expose another user's company" do
    sign_out
    sign_in_as(users(:two))

    get company_url(@northstar)

    assert_response :not_found
  end
end
