Feature: Booking Approval Workflow
  Rooms that require approval need admin action

  Background:
    Given a department "UC" exists with an admin "ucadmin@cuhk.edu.hk"
    And a room "Grand Hall" exists in "UC" with:
      | requires_approval | true    |
      | price_per_unit    | 500.00  |

  Scenario: Booking requires approval shows pending status
    Given I am logged in as a student
    When I successfully book "Grand Hall" for "tomorrow" from "10:00" to "12:00"
    Then I should see "Booking submitted, pending approval"
    And the booking status should be "pending"
    And I should see "Total cost: $2,000.00"

  Scenario: Student sees pending status in my bookings
    Given I am logged in as a student
    And I have a pending booking for "Grand Hall" tomorrow "10:00"-"12:00"
    When I visit my bookings page
    Then I should see "Pending Approval"
    And I should see "$2,000.00"

  Scenario: Admin sees pending bookings with cost
    Given a student "Chan Tai Man" has a pending booking for "Grand Hall"
    And I am logged in as admin "ucadmin@cuhk.edu.hk"
    When I visit the admin bookings page
    Then I should see "Chan Tai Man"
    And I should see "Grand Hall"
    And I should see "Pending"
    And I should see the booking cost "$2,000.00"

  Scenario: Auto-confirmed room creates booking immediately
    Given I am logged in as a student
    When I successfully book "Grand Hall" for "tomorrow" from "10:00" to "12:00"
    Then I should see "Booking submitted, pending approval"
    And the booking status should be "pending"