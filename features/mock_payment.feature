Feature: Payment for Paid Bookings
  As a student
  I want to complete payment for paid room/equipment bookings
  So that my booking is confirmed

  Background:
    Given a paid room "VIP Room" exists in "UC" with price_per_unit 300.00
    And I am logged in as a student
    And a department "UC" exists

  Scenario: Paid booking redirects to payment page
    When I visit the rooms page
    And I click "VIP Room"
    Then I should see "VIP Room"
