Feature: Create Booking
  As a student
  After selecting time slots, I want to confirm and submit my booking

  Background:
    Given a department "UC" exists
    And a room "Meeting Room A" exists in "UC" with:
      | building              | UC Building  |
      | room_type             | Meeting Room |
      | location              | 1/F          |
      | capacity              | 20           |
      | max_slots_per_booking | 8            |
      | requires_approval     | false        |
      | price_per_unit        | 0.00         |
    And a room "VIP Room" exists in "UC" with:
      | building              | UC Building  |
      | room_type             | Meeting Room |
      | location              | 5/F          |
      | capacity              | 15           |
      | max_slots_per_booking | 4            |
      | requires_approval     | true         |
      | price_per_unit        | 300.00       |
    And I am logged in as a student

  Scenario: Complete booking flow for free room
    When I visit the rooms page
    And I click "Meeting Room A"
    Then I should see "Meeting Room A"
    When I select date "tomorrow"
    And I select slots from "10:00" to "12:00"
    And I click "Proceed to Book"
    Then I should see the booking confirmation form with:
      | Room     | Meeting Room A  |
      | Date     | tomorrow        |
      | Time     | 10:00 – 12:00   |
      | Duration | 2 hours         |
      | Cost     | Free            |
    When I fill in "Purpose" with "Drama Society rehearsal"
    And I click "Confirm Booking"
    Then I should see "Booking confirmed"
    And I should be on my bookings page

  Scenario: Complete booking flow for paid room
    When I visit the rooms page
    And I click "VIP Room"
    Then I should see "VIP Room"
    When I select date "tomorrow"
    And I select slots from "14:00" to "16:00"
    And I click "Proceed to Book"
    Then I should see the booking confirmation form with:
      | Room     | VIP Room    |
      | Date     | tomorrow    |
      | Time     | 14:00 – 16:00 |
      | Duration | 2 hours     |
    When I fill in "Purpose" with "Board meeting"
    And I click "Confirm Booking"
    Then I should see "Booking confirmed" or "Booking submitted"