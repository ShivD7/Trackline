require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end


  test "requires a unique valid email and a secure password" do
    duplicate = User.new(email_address: users(:one).email_address, password: "short")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email_address], "has already been taken"
    assert_includes duplicate.errors[:password], "is too short (minimum is 8 characters)"
  end
end
