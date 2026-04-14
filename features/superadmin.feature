Feature: Superadmin Controls
  As a superadmin
  I want to manage all system resources
  Including all departments

  Background:
    Given I am logged in as a superadmin

  Scenario: Superadmin can access admin resources
    When I visit the admin resources page
    Then I should see "Admin"

  Scenario: Superadmin can manage all departments
    Given a department "UC" exists
    And a department "NA" exists
    When I visit the admin resources page
    Then I should see "UC"
    And I should see "NA"