Feature: My Bookings
  As a student
  I want to view my bookings

  Background:
    Given a department "UC" exists
    And a room "Room A" exists in "UC"
    And I am logged in as a student

  Scenario: View bookings page
    When I visit my bookings page
    Then I should see "Welcome"
