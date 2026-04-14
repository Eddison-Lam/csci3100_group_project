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
      | Cost     | $1200.00 (4 slots × $300.00) |
      | Total cost      | $1,200.00   |
    When I fill in "Purpose" with "Board meeting"
    And I click "Confirm Booking"
    Then I should see "Booking submitted, pending approval"
    And the booking status should be "pending"

  Scenario: Booking that requires approval shows warning
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "11:00" for "VIP Room"
    And I click "Book This Room" for "VIP Room"
    Then I should see "This room requires approval"
    And I should see "Total cost: $600.00"

  Scenario: Purpose is required
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "Meeting Room A"
    And I click "Book This Room" for "Meeting Room A"
    And I leave "Purpose" empty
    And I click "Confirm Booking"
    Then I should see "Purpose can't be blank"
    And the booking should not be created

  Scenario: Notes are optional
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "Meeting Room A"
    And I click "Book This Room" for "Meeting Room A"
    And I fill in "Purpose" with "Meeting"
    And I leave "Notes" empty
    And I click "Confirm Booking"
    Then I should see "Booking confirmed"

  Scenario: Cancel from confirmation page
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "Meeting Room A"
    And I click "Book This Room" for "Meeting Room A"
    And I click "Cancel"
    Then I should be on the rooms page

  Scenario: Slot becomes booked while filling form (race condition)
    Given I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "Meeting Room A"
    And I click "Book This Room" for "Meeting Room A"
    And another user books "Meeting Room A" on "tomorrow" from "10:00" to "11:00"
    When I fill in "Purpose" with "My meeting"
    And I click "Confirm Booking"
    Then I should see "Time slot conflicts with existing booking"

  Scenario: Auto-confirmed room creates confirmed booking immediately
    Given a room "Quick Room" exists with requires_approval false
    When I successfully book "Quick Room" for tomorrow "10:00"-"12:00"
    Then I should see "Booking confirmed"
    And the booking status should be "confirmed"
    And I should receive a confirmation email

  Scenario: Approval-required room creates pending booking
    Given a room "VIP Room" exists with requires_approval true
    When I successfully book "VIP Room" for tomorrow "10:00"-"12:00"
    Then I should see "Booking submitted, pending approval"
    And the booking status should be "pending"
    And I should not receive a confirmation email yet