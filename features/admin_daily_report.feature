Feature: Admin Dashboard
  As a department admin
  I want to see admin dashboard
  So that I can manage resources

  Background:
    Given a department "UC" with admin "ucadmin@cuhk.edu.hk"
    And I am logged in as admin "ucadmin@cuhk.edu.hk"

  Scenario: Admin can access admin resources page
    When I visit the admin resources page
    Then I should see "Admin"