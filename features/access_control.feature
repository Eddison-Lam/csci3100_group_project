Feature: Access Control
  Role-based access restrictions

  Scenario: Guest sees login and register buttons on home page
    When I go to the home page
    Then I should see "CUHK Venue & Equipment Booking"
    And I should see "Register"
    And I should see "Login"

  Scenario: Guest can register a student account
    When I register as a student with email "student@link.cuhk.edu.hk"
    Then I should see "Welcome"
    And I should see "Book a Room"

  Scenario: Student cannot access admin pages
    Given I am logged in as a student
    When I try to visit the admin resources page
    Then I should be redirected to the home page
    And I should see "You are not authorized to view this page"

  Scenario: Admin cannot manage other department resources
    Given a department "UC" with admin "ucadmin@cuhk.edu.hk"
    And a department "NA" exists
    And a room "NA Room" exists in "NA"
    And I am logged in as admin "ucadmin@cuhk.edu.hk"
    When I visit the admin resources page
    Then I should see "Admin Resources"
    And the page should not contain "NA Room"

  Scenario: Superadmin can manage all departments
    Given a department "UC" exists
    And a department "NA" exists
    And a room "UC Room" exists in "UC"
    And a room "NA Room" exists in "NA"
    And I am logged in as a superadmin
    When I visit the admin resources page
    Then I should see "UC Room"
    And I should see "NA Room"

  Scenario: Student can only see own bookings
    Given a student "other@link.cuhk.edu.hk" exists
    And I am logged in as a student
    When I visit my bookings page
    Then I should not see the other student's booking