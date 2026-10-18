puts "Resetting demo data…"
StageChange.delete_all
Note.delete_all
JobApplication.delete_all
Company.delete_all
Session.delete_all
User.delete_all

demo_user = User.create!(
  email_address: ENV.fetch("TRACKLINE_DEMO_EMAIL", "demo@trackline.app"),
  password: ENV.fetch("TRACKLINE_DEMO_PASSWORD", "password123")
)

companies = {
  shopify: demo_user.companies.create!(name: "Shopify", website: "https://www.shopify.com", industry: "Commerce", headquarters: "Ottawa, ON"),
  wealthsimple: demo_user.companies.create!(name: "Wealthsimple", website: "https://www.wealthsimple.com", industry: "Fintech", headquarters: "Toronto, ON"),
  notion: demo_user.companies.create!(name: "Notion", website: "https://www.notion.so", industry: "Productivity", headquarters: "San Francisco, CA"),
  linear: demo_user.companies.create!(name: "Linear", website: "https://linear.app", industry: "Developer tools", headquarters: "San Francisco, CA"),
  figma: demo_user.companies.create!(name: "Figma", website: "https://www.figma.com", industry: "Design software", headquarters: "San Francisco, CA")
}

applications = [
  {
    company: companies[:shopify], role_title: "Backend Developer Intern", status: "interviewing", priority: "high",
    location: "Toronto, ON", work_mode: "hybrid", source: "Campus recruiter", applied_on: 18.days.ago.to_date,
    follow_up_on: 2.days.from_now.to_date, salary_range: "$32–$38/hr", contact_name: "Maya Chen",
    contact_email: "maya@example.com", job_url: "https://www.shopify.com/careers",
    description: "Prepare examples about shipping iteratively, working with ambiguity, and improving developer experience. Revisit the inventory project architecture before the technical conversation."
  },
  {
    company: companies[:wealthsimple], role_title: "Software Engineer Intern", status: "screening", priority: "high",
    location: "Toronto, ON", work_mode: "remote", source: "Referral", applied_on: 9.days.ago.to_date,
    follow_up_on: Date.current, salary_range: "$35–$42/hr", description: "Recruiter screen focused on product thinking and collaboration."
  },
  {
    company: companies[:notion], role_title: "Product Engineering Intern", status: "applied", priority: "medium",
    location: "New York, NY", work_mode: "hybrid", source: "Company website", applied_on: 5.days.ago.to_date,
    follow_up_on: 5.days.from_now.to_date
  },
  {
    company: companies[:linear], role_title: "Software Engineer, Early Career", status: "wishlist", priority: "medium",
    location: "Remote", work_mode: "remote", source: "LinkedIn", follow_up_on: nil,
    description: "Tailor portfolio notes around UI craft and performance before applying."
  },
  {
    company: companies[:figma], role_title: "Software Engineer Intern", status: "rejected", priority: "low",
    location: "San Francisco, CA", work_mode: "hybrid", source: "Career fair", applied_on: 34.days.ago.to_date
  }
]

applications.each do |attributes|
  application = JobApplication.create!(attributes)
  application.stage_changes.create!(to_status: "wishlist", changed_at: application.created_at)
  next if application.wishlist?

  application.stage_changes.create!(from_status: "wishlist", to_status: "applied", changed_at: application.applied_on.to_time)
  if application.status != "applied"
    application.stage_changes.create!(from_status: "applied", to_status: application.status, changed_at: [ application.updated_at - 2.days, application.applied_on.to_time ].max)
  end
end

shopify = JobApplication.find_by!(role_title: "Backend Developer Intern")
shopify.notes.create!(occurred_on: 6.days.ago.to_date, body: "Recruiter screen went well. Team values pragmatic decisions and clear written communication.")
shopify.notes.create!(occurred_on: 2.days.ago.to_date, body: "Technical interview booked. Review Active Record query patterns and prepare two thoughtful questions about team ownership.")

puts "Created #{Company.count} companies, #{JobApplication.count} applications, and #{Note.count} notes for #{demo_user.email_address}."
#   end
