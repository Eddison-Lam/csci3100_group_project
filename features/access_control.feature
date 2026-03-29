Feature: Access Control
  Role-based access restrictions

  Scenario: Guest redirected to login
    When I go to the home page
    Then I should be on the login page

  Scenario: Student cannot access admin pages
    Given I am logged in as a student
    When I visit the admin home page 
    Then I should be redirected to the student home page
    And I should see "Access denied"

  Scenario: Admin cannot manage other department resources
    Given a department "UC" with admin "ucadmin@cuhk.edu.hk"
    And a department "NA" exists
    And a room "NA Room" exists in "NA"
    And I am logged in as admin "ucadmin@cuhk.edu.hk"
    When I try to edit resource "NA Room"
    Then I should see "Access denied"

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
    And "other@link.cuhk.edu.hk" has a booking
    And I am logged in as a student
    When I visit my bookings page
    Then I should not see the other student's booking