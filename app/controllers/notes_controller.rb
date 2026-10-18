class NotesController < ApplicationController
  before_action :set_job_application

  def create
    @note = @job_application.notes.build(note_params)
    if @note.save
      redirect_to @job_application, notice: "Note added."
    else
      @job_application = current_user.job_applications.includes(:company, :notes, :stage_changes).find(@job_application.id)
      render "job_applications/show", status: :unprocessable_entity
    end
  end

  def destroy
    @job_application.notes.find(params[:id]).destroy!
    redirect_to @job_application, notice: "Note removed."
  end

  private

  def set_job_application
    @job_application = current_user.job_applications.find(params[:job_application_id])
  end

  def note_params
    params.require(:note).permit(:body, :occurred_on)
  end
end
