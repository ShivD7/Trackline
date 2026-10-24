require "application_system_test_case"

class JobSearchTest < ApplicationSystemTestCase
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
