class JobApplicationsController < ApplicationController
  before_action :set_job_application, only: %i[show edit update destroy duplicate]

  def index
    @job_applications = JobApplication.includes(:company).search(params[:q])
    @job_applications = @job_applications.where(status: params[:status]) if params[:status].present?
    @job_applications = @job_applications.where(priority: params[:priority]) if params[:priority].present?
    @job_applications = @job_applications.where(work_mode: params[:work_mode]) if params[:work_mode].present?
    @job_applications = @job_applications.order(sort_order)
  end

  def pipeline
    applications = JobApplication.includes(:company).recent_first
    @applications_by_status = applications.group_by(&:status)
  end

  def show
    @note = @job_application.notes.build(occurred_on: Date.current)
  end

  def new
    @job_application = JobApplication.new(status: :wishlist, priority: :medium)
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

  private

  def set_job_application
    @job_application = JobApplication.includes(:company, :notes, :stage_changes).find(params[:id])
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

    Company.where("lower(name) = ?", name.downcase).first_or_initialize.tap { |company| company.name = name }
  end

  def sort_order
    {
      "oldest" => { updated_at: :asc },
      "follow_up" => { follow_up_on: :asc },
      "company" => { companies: { name: :asc } }
    }.fetch(params[:sort], { updated_at: :desc })
  end
end
