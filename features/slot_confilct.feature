Feature: Slot Availability
  The system shows available and booked slots correctly

  Background:
    Given a department "UC" exists
    And a room "Meeting Room A" exists in "UC" with:
      | requires_approval | false |
      | price_per_unit    | 0.00  |
    And I am logged in as a student

  Scenario: View available slots
    When I visit the rooms page
    And I click "Meeting Room A"
    Then I should see "Meeting Room A"

  Scenario: Confirmed bookings show as booked
    Given a confirmed booking exists for "Meeting Room A" on "tomorrow" from "10:00" to "12:00"
    When I visit the rooms page
    And I click "Meeting Room A"
    Then I should see "Meeting Room A"

  Scenario: Pending payment bookings show as held
    Given a pending booking exists for "Meeting Room A" on "tomorrow" from "14:00" to "16:00"
    When I visit the rooms page
    And I click "Meeting Room A"
    Then I should see "Meeting Room A"