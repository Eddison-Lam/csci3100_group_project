Feature: Create Booking
  As a student
  After selecting time slots, I want to confirm and submit my booking

  Background:
    Given a department "UC" exists
    And a room "UC Meeting A" exists in "UC" with:
      | building              | UC Building  |
      | room_type             | Meeting Room |
      | location              | 2/F          |
      | capacity              | 30           |
      | max_slots_per_booking | 8            |
      | requires_approval     | false        |
      | price_per_unit        | 0.00         |
    And a room "UC Meeting B" exists in "UC" with:
      | building              | UC Building  |
      | room_type             | Meeting Room |
      | location              | 3/F          |
      | capacity              | 20           |
      | max_slots_per_booking | 4            |
      | requires_approval     | true         |
      | price_per_unit        | 50.00       |
    And I am logged in as a student

  Scenario: Room booking can be created
    When I visit the rooms page
    Then I should see "UC Meeting A"
    And I should see "UC Meeting B"