require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "redirects guests to sign in and returns them after authentication" do
    get job_applications_path

    assert_redirected_to new_session_path

    post session_path, params: { email_address: users(:one).email_address, password: "password" }

    assert_redirected_to job_applications_url
  end
end
