class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  layout "authentication"
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    redirect_to root_path and return if authenticated?

    @user = User.new
  end

  def create
    redirect_to root_path and return if authenticated?

    @user = User.new(registration_params)
    first_account = User.none?

    User.transaction do
      @user.save!
      Company.where(user_id: nil).update_all(user_id: @user.id) if first_account
    end

    start_new_session_for(@user)
    redirect_to root_path, notice: "Welcome to Trackline. Your private workspace is ready."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
