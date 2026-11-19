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
    @follow_ups = applications.includes(:company).active.where(follow_up_on: ..14.days.from_now.to_date).order(:follow_up_on).limit(6)
    @overdue_count = applications.follow_up_due.where("follow_up_on < ?", Date.current).count
    @today_count = applications.active.where(follow_up_on: Date.current).count
    @upcoming_count = applications.upcoming_follow_ups.where("follow_up_on > ?", Date.current).count
    first_week = Date.current.beginning_of_week - 3.weeks
    daily_counts = applications.where(applied_on: first_week..Date.current).group(:applied_on).count
    @weekly_activity = 4.times.map do |offset|
      week = first_week + offset.weeks
      [ week, daily_counts.sum { |date, count| date.in?(week..week.end_of_week) ? count : 0 } ]
    end
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
