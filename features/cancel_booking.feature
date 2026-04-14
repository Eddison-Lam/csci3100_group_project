Feature: Cancel Booking
  As a student
  I want to cancel my bookings

  Background:
    Given a department "UC" exists
    And a room "Room A" exists in "UC"
    And I am logged in as a student

  Scenario: View my bookings page
    When I visit my bookings page
    Then I should see "My Bookings"
