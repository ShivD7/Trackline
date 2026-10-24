require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "creates an account and signs the user in" do
    assert_difference [ "User.count", "Session.count" ], 1 do
      post registration_path, params: {
        user: {
          email_address: "NEW@EXAMPLE.COM ",
          password: "secure-password",
          password_confirmation: "secure-password"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "new@example.com", User.order(:created_at).last.email_address
    assert cookies[:session_id]
  end

  test "rejects invalid registration details" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: "not-an-email",
          password: "short",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".form-errors"
  end

  test "registration never claims unowned legacy companies" do
    legacy = Company.new(name: "Legacy")
    legacy.save!(validate: false)

    post registration_path, params: {
      user: { email_address: "fresh@example.com", password: "secure-password", password_confirmation: "secure-password" }
    }

    assert_redirected_to root_path
    assert_nil legacy.reload.user_id
  end

  test "redirects signed-in users away from registration" do
    sign_in_as(users(:one))

    get new_registration_path

    assert_redirected_to root_path
  end
end
