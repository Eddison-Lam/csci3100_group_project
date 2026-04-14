Feature: View Bookings Waitlist
  As a student
  I want to see available slots
  So that I can book when slots are full

  Background:
    Given a department "UC" exists
    And a room "Room A" exists in "UC"
    And I am logged in as a student

  Scenario: View available slots
    When I visit the rooms page
    And I click "Room A"
    Then I should see "Room A"