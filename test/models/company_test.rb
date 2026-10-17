require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "normalizes and validates company names case-insensitively" do
    Company.create!(name: "  Shopify  ")
    duplicate = Company.new(name: "shopify")

    assert_equal "Shopify", Company.first.name
    assert_not duplicate.valid?
  end

  test "does not delete a company that still has applications" do
    company = Company.create!(name: "Acme")
    JobApplication.create!(company: company, role_title: "Engineer")

    assert_not company.destroy
    assert_includes company.errors.full_messages.join, "applications"
  end
end
