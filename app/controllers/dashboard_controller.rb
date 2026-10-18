class DashboardController < ApplicationController
  def index
    applications = current_user.job_applications
    @status_counts = applications.group(:status).count
    @total_applications = applications.count
    @active_applications = applications.active.count
    @offers = @status_counts.fetch("offer", 0)
    @stage_moves_this_week = StageChange.where(job_application_id: applications.select(:id), changed_at: 7.days.ago..).count
    @response_rate = response_rate(applications)
    @recent_applications = applications.includes(:company).recent_first.limit(6)
    @follow_ups = applications.includes(:company).upcoming_follow_ups.order(:follow_up_on).limit(6)
    @overdue_count = applications.follow_up_due.where("follow_up_on < ?", Date.current).count
  end

  def follow_ups
    applications = current_user.job_applications.includes(:company).active.where.not(follow_up_on: nil)
    @overdue_follow_ups = applications.where(follow_up_on: ...Date.current).order(:follow_up_on)
    @today_follow_ups = applications.where(follow_up_on: Date.current).order(updated_at: :desc)
    @upcoming_follow_ups = applications.where(follow_up_on: Date.tomorrow..).order(:follow_up_on)
  end

  private

  def response_rate(applications)
    applied = applications.where.not(status: :wishlist).count
    responded = applications.where(status: %i[screening interviewing offer rejected]).count
    applied.zero? ? 0 : ((responded.to_f / applied) * 100).round
  end
end
