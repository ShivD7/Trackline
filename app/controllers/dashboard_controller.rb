class DashboardController < ApplicationController
  def index
    @status_counts = JobApplication.group(:status).count
    @total_applications = JobApplication.count
    @active_applications = JobApplication.active.count
    @offers = @status_counts.fetch("offer", 0)
    @response_rate = response_rate
    @recent_applications = JobApplication.includes(:company).recent_first.limit(6)
    @follow_ups = JobApplication.includes(:company).upcoming_follow_ups.order(:follow_up_on).limit(6)
    @overdue_count = JobApplication.follow_up_due.where("follow_up_on < ?", Date.current).count
  end

  def follow_ups
    applications = JobApplication.includes(:company).active.where.not(follow_up_on: nil)
    @overdue_follow_ups = applications.where(follow_up_on: ...Date.current).order(:follow_up_on)
    @today_follow_ups = applications.where(follow_up_on: Date.current).order(updated_at: :desc)
    @upcoming_follow_ups = applications.where(follow_up_on: Date.tomorrow..).order(:follow_up_on)
  end

  private

  def response_rate
    applied = JobApplication.where.not(status: :wishlist).count
    responded = JobApplication.where(status: %i[screening interviewing offer rejected]).count
    applied.zero? ? 0 : ((responded.to_f / applied) * 100).round
  end
end
