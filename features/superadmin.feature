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
    When I visit the admin resources page
    Then I should see "Admin Resources"