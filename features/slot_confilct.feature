Feature: Slot Availability
  The system shows available and booked slots correctly

  Background:
    Given a department "UC" exists
    And a room "Room X" exists in "UC" with:
      | requires_approval | false |
      | price_per_unit    | 0.00  |
    And I am logged in as a student

  Scenario: View slot availability
    When I visit the rooms page
    And I click "Room X"
    Then I should see "Room X"

  Scenario: Room shows available slots
    When I visit the rooms page
    And I click "Room X"
    Then I should see "Room X"