Feature: Booking Status Management
  As a department admin
  I want to see booking status
  So that I can manage bookings

  Background:
    Given a department "UC" exists
    And a room "Room A" exists in "UC" with price_per_unit 0.00
    And I am logged in as a student

  Scenario: View confirmed booking
    Given I have a confirmed booking for "Room A" tomorrow "10:00"-"11:00"
    When I visit my bookings page
    Then I should see "Room A"
