Feature: Payment for Paid Bookings
  As a student
  I want to complete payment for paid room/equipment bookings
  So that my booking is confirmed

  Background:
    Given I am logged in as a student
    And a room "CYT Practice Room 201" exists with price_per_unit 60.0

  Scenario: Paid booking exists
    When I am on the rooms page
    And I click "CYT Practice Room 201"
    Then I should see "CYT Practice Room 201"

