require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "normalizes and validates company names case-insensitively" do
    Company.create!(user: @user, name: "  Shopify  ")
    duplicate = Company.new(user: @user, name: "shopify")

    assert_equal "Shopify", @user.companies.first.name
    assert_not duplicate.valid?
  end

  test "allows different users to track the same company" do
    Company.create!(user: @user, name: "Shopify")

    assert Company.new(user: users(:two), name: "shopify").valid?
  end

  test "does not delete a company that still has applications" do
    company = Company.create!(user: @user, name: "Acme")
    JobApplication.create!(company: company, role_title: "Engineer")

    assert_not company.destroy
    assert_includes company.errors.full_messages.join, "applications"
  end
end
