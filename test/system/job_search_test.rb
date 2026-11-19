require "application_system_test_case"

class JobSearchTest < ApplicationSystemTestCase
  test "phone navigation, validation focus, and focused stage updates remain accessible" do
    page.current_window.resize_to(390, 844)
    visit new_session_path
    fill_in "Email address", with: users(:one).email_address
    fill_in "Password", with: "password"
    click_on "Sign in", exact: true
    assert_text "Good"

    find(".mobile-menu summary").click
    assert_selector ".mobile-menu[open]"
    within ".mobile-menu" do
      click_on "Applications", exact: true
    end
    assert_selector "h1", text: "Applications"

    click_on "Add application", exact: true
    fill_in "Company", with: "Phone employer"
    fill_in "Role title", with: "Accessible role"
    click_on "Add application", exact: true
    assert_text "Application added"

    click_on "Add note"
    assert_selector ".form-errors", text: "Body can't be blank"
    assert_equal "true", find("#note_body")["aria-invalid"]
    assert_equal "form-errors", page.evaluate_script("document.activeElement.className")
    within ".form-errors" do
      click_on "Body can't be blank"
    end
    assert_equal "note_body", page.evaluate_script("document.activeElement.id")

    within ".stage-form" do
      select "Screening", from: "Stage"
      click_on "Save stage"
    end
    assert_text "Application updated"
    assert_selector ".timeline", text: "Screening"
    assert_no_selector ".form-errors"
    assert_operator page.evaluate_script("document.documentElement.scrollWidth"), :<=, page.evaluate_script("window.innerWidth")
    save_screenshot Rails.root.join("tmp/screenshots/trackline-phone.png")
    page.current_window.resize_to(1400, 1000)
    visit job_applications_path
    assert_selector ".applications-table"
    save_screenshot Rails.root.join("tmp/screenshots/trackline-desktop.png")
  end

  test "a new user can manage a job search and sign back in" do
    visit new_registration_path
    fill_in "Email address", with: "browser@example.com"
    fill_in "Password", with: "browser-password", exact: true
    fill_in "Confirm password", with: "browser-password"
    click_on "Create account"
    assert_text "Your private workspace is ready"

    visit new_company_path
    fill_in "Name", with: "Browser employer"
    fill_in "Website", with: "https://example.com"
    click_on "Create Company"
    assert_text "Company added"
    click_on "Add role"
    fill_in "Role title", with: "Rails internship"
    select "Applied", from: "Status"
    assert_field "Applied on", with: Date.current.iso8601
    fill_in "Follow up on", with: Date.current
    assert_field "Follow up on", with: Date.current.iso8601
    click_on "Add application"
    assert_text "Application added"

    fill_in "note_body", with: "Prepare for the interview"
    click_on "Add note"
    assert_text "Prepare for the interview"
    click_on "Mark follow-up complete"
    assert_text "Follow-up marked complete"

    click_on "Edit", exact: true
    select "Interviewing", from: "Status"
    click_on "Save changes"
    assert_text "Application updated"
    assert_selector ".timeline", text: "Interviewing"

    click_on "Applications", match: :first
    fill_in "Search applications", with: "Rails internship"
    click_on "Apply", exact: true
    assert_text "Rails internship"

    click_on "Sign out", match: :first
    assert_text "Sign in to Trackline"
    fill_in "Email address", with: "browser@example.com"
    fill_in "Password", with: "browser-password"
    click_on "Sign in", exact: true
    assert_text "Rails internship"
  end
end
