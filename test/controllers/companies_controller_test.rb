require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Company.create!(name: "Northstar", industry: "Fintech", headquarters: "Toronto")
    Company.create!(name: "Bluebird", industry: "Healthcare", headquarters: "Montreal")
  end

  test "searches companies by profile details" do
    get companies_url, params: { q: "Toronto" }

    assert_response :success
    assert_select ".company-card", count: 1
    assert_select ".company-card h2", text: "Northstar"
  end
end
