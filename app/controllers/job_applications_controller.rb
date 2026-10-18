class JobApplicationsController < ApplicationController
  before_action :set_job_application, only: %i[show edit update destroy duplicate complete_follow_up]

  def index
    @job_applications = current_user.job_applications.includes(:company).search(params[:q])
    @job_applications = @job_applications.where(status: params[:status]) if params[:status].present?
    @job_applications = @job_applications.where(priority: params[:priority]) if params[:priority].present?
    @job_applications = @job_applications.where(work_mode: params[:work_mode]) if params[:work_mode].present?
    @job_applications = filter_by_follow_up(@job_applications)
    @job_applications = sort_applications(@job_applications)
  end

  def pipeline
    applications = current_user.job_applications.includes(:company).recent_first
    @applications_by_status = applications.group_by(&:status)
  end

  def show
    @note = @job_application.notes.build(occurred_on: Date.current)
  end

  def new
    @job_application = JobApplication.new(status: :wishlist, priority: :medium)
    @job_application.company = current_user.companies.find_by(id: params[:company_id]) if params[:company_id].present?
  end

  def create
    @job_application = JobApplication.new(job_application_params.except(:company_name))
    @job_application.company = company_from_params

    if @job_application.save
      @job_application.stage_changes.create!(to_status: @job_application.status, changed_at: Time.current)
      redirect_to @job_application, notice: "Application added to your pipeline."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @job_application.company = company_from_params

    if ApplicationStatusUpdater.call(application: @job_application, attributes: job_application_params.except(:company_name))
      redirect_to @job_application, notice: "Application updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job_application.destroy!
    redirect_to job_applications_path, notice: "Application removed."
  end

  def duplicate
    copy = @job_application.dup
    copy.assign_attributes(status: :wishlist, applied_on: nil, follow_up_on: nil)

    ApplicationRecord.transaction do
      copy.save!
      copy.stage_changes.create!(to_status: copy.status, changed_at: Time.current)
    end

    redirect_to edit_job_application_path(copy), notice: "Application copied. Review the details before saving."
  end

  def complete_follow_up
    @job_application.update!(follow_up_on: nil)
    redirect_back fallback_location: @job_application, notice: "Follow-up marked complete."
  end

  private

  def set_job_application
    @job_application = current_user.job_applications.includes(:company, :notes, :stage_changes).find(params[:id])
  end

  def job_application_params
    params.require(:job_application).permit(
      :company_name, :role_title, :status, :priority, :work_mode, :location, :source,
      :job_url, :salary_range, :contact_name, :contact_email, :applied_on,
      :follow_up_on, :description
    )
  end

  def company_from_params
    name = job_application_params[:company_name].to_s.squish
    return @job_application.company if name.blank? && @job_application.persisted?

    current_user.companies.where("lower(name) = ?", name.downcase).first_or_initialize.tap { |company| company.name = name }
  end

  def sort_applications(scope)
    case params[:sort]
    when "oldest" then scope.order(updated_at: :asc)
    when "follow_up" then scope.order(Arel.sql("follow_up_on IS NULL, follow_up_on ASC"))
    when "company" then scope.references(:company).order(Arel.sql("lower(companies.name) ASC"))
    else scope.order(updated_at: :desc)
    end
  end

  def filter_by_follow_up(scope)
    case params[:follow_up]
    when "overdue" then scope.active.where(follow_up_on: ...Date.current)
    when "today" then scope.active.where(follow_up_on: Date.current)
    when "upcoming" then scope.active.where(follow_up_on: Date.tomorrow..14.days.from_now.to_date)
    when "none" then scope.active.where(follow_up_on: nil)
    when "stale" then scope.stale
    else scope
    end
  end
end
