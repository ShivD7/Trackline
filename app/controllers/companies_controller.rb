class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy]

  def index
    @companies = current_user.companies.search(params[:q]).left_joins(:job_applications)
      .select("companies.*, COUNT(job_applications.id) AS applications_count")
      .group("companies.id")
      .alphabetical
  end

  def show
    @job_applications = @company.job_applications.recent_first
  end

  def new
    @company = current_user.companies.build
  end

  def create
    @company = current_user.companies.build(company_params)
    if @company.save
      redirect_to @company, notice: "Company added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: "Company updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @company.destroy
      redirect_to companies_path, notice: "Company removed."
    else
      redirect_to @company, alert: "Remove its applications before deleting this company."
    end
  end

  private

  def set_company
    @company = current_user.companies.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :website, :industry, :headquarters)
  end
end
