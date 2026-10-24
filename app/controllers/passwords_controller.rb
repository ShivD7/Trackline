class PasswordsController < ApplicationController
  allow_unauthenticated_access
  layout "authentication"
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_now
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  rescue StandardError => error
    Rails.logger.error("Password reset delivery failed: #{error.class.name}")
    redirect_to new_password_path, alert: "Unable to send reset instructions. Please try again later."
  end

  def edit
  end

  def update
    @user.assign_attributes(params.permit(:password, :password_confirmation))
    if params[:password].blank?
      @user.errors.add(:password, "can't be blank")
      render :edit, status: :unprocessable_entity
    elsif @user.valid?
      User.transaction do
        @user.save!
        @user.sessions.destroy_all
      end
      cookies.delete(:session_id)
      reset_session
      redirect_to new_session_path, notice: "Password has been reset."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
