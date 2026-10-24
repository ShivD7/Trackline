require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset email includes a usable link for the configured app address" do
    user = users(:one)
    email = PasswordsMailer.reset(user)

    assert_equal [ user.email_address ], email.to
    assert_includes email.text_part.body.decoded, "http://127.0.0.1:3001/passwords/"
    assert_includes email.html_part.body.decoded, user.password_reset_token
  end
end
