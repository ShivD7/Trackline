namespace :accounts do
  desc "Assign legacy records to an existing account: EMAIL=you@example.com"
  task claim_legacy: :environment do
    abort "Legacy records can only be assigned locally in development." unless Rails.env.development?
    user = User.find_by!(email_address: ENV.fetch("EMAIL").strip.downcase)
    count = Company.where(user_id: nil).update_all(user_id: user.id)
    puts "Assigned #{count} legacy companies and their applications to #{user.email_address}."
  end
end
