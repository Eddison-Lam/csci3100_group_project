Feature: Superadmin Settings
  As a superadmin
  I want to configure system-wide settings
  Including booking lock timeout

  Background:
    Given I am logged in as a superadmin

  Scenario: View current lock timeout setting
    When I visit the admin settings page
    Then I should see "Booking lock timeout: 5 minutes"

  Scenario: Change lock timeout
    When I visit the admin settings page
    And I fill in "Booking lock timeout (minutes)" with "10"
    And I click "Save Settings"
    Then I should see "Settings updated"
    And the booking lock timeout should be 10 minutes

  Scenario: Minimum lock timeout validation
    When I visit the admin settings page
    And I fill in "Booking lock timeout (minutes)" with "0"
    And I click "Save Settings"
    Then I should see "Lock timeout must be at least 1 minute"

  Scenario: Maximum lock timeout validation
    When I visit the admin settings page
    And I fill in "Booking lock timeout (minutes)" with "30"
    And I click "Save Settings"
    Then I should see "Lock timeout cannot exceed 30 minutes"

  Scenario: Lock timeout affects new bookings immediately
    Given the booking lock timeout is 5 minutes
    When I change the lock timeout to 10 minutes
    And a student creates a new booking lock
    Then the lock should expire in 10 minutes