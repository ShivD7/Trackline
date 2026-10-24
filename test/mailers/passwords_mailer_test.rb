require "test_helper"
require "tmpdir"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset email includes a usable link for the configured app address" do
    user = users(:one)
    email = PasswordsMailer.reset(user)

    assert_equal [ user.email_address ], email.to
    assert_includes email.text_part.body.decoded, "http://127.0.0.1:3001/passwords/"
    link = URI.extract(email.text_part.body.decoded, [ "http", "https" ]).first
    token = Rails.application.routes.recognize_path(URI.parse(link).path).fetch(:token)
    assert_equal user, User.find_by_password_reset_token!(token)
  end

  test "local delivery saves a readable reset link without needing an SMTP account" do
    Dir.mktmpdir("trackline-mail-test") do |directory|
      message = PasswordsMailer.reset(users(:one)).message
      Trackline::LocalMailDelivery.new(location: directory).deliver!(message)

      files = Dir.glob(File.join(directory, "*.txt"))
      assert_equal 1, files.size
      content = File.read(files.first)
      assert_includes content, "To: #{users(:one).email_address}"
      link = URI.extract(content, [ "http", "https" ]).first
      token = Rails.application.routes.recognize_path(URI.parse(link).path).fetch(:token)
      assert_equal users(:one), User.find_by_password_reset_token!(token)
    end
  end
end
