module ApplicationHelper
  STATUS_LABELS = {
    "wishlist" => "Wishlist",
    "applied" => "Applied",
    "screening" => "Screening",
    "interviewing" => "Interviewing",
    "offer" => "Offer",
    "rejected" => "Rejected",
    "withdrawn" => "Withdrawn"
  }.freeze

  def page_title(title)
    content_for(:title, "#{title} · Trackline")
  end

  def status_label(status)
    STATUS_LABELS.fetch(status.to_s, status.to_s.humanize)
  end

  def nav_link(label, path, match: nil, exclude: nil)
    active = match ? request.path.start_with?(match) : current_page?(path)
    active = false if exclude && request.path.start_with?(exclude)
    link_to label, path, class: class_names("nav-link", active: active), "aria-current": ("page" if active)
  end

  def formatted_date(date, fallback: "Not set")
    date.present? ? date.strftime("%b %-d, %Y") : fallback
  end

  def initials(name)
    name.to_s.split.first(2).map { |word| word.first.upcase }.join
  end

  def safe_external_url(value)
    uri = URI.parse(value.to_s)
    uri.to_s if uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end
end
