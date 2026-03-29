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

  Scenario: Admin approves a booking
    Given a student "Chan Tai Man" has a pending booking for "Grand Hall"
    And I am logged in as admin "ucadmin@cuhk.edu.hk"
    When I visit the admin bookings page
    And I click "Approve" for the booking by "Chan Tai Man"
    Then I should see "Booking approved"
    And the booking status should be "confirmed"

  Scenario: Admin rejects a booking with reason
    Given a student "Chan Tai Man" has a pending booking for "Grand Hall"
    And I am logged in as admin "ucadmin@cuhk.edu.hk"
    When I visit the admin bookings page
    And I fill in "Rejection reason" with "Under maintenance"
    And I click "Reject" for the booking by "Chan Tai Man"
    Then I should see "Booking rejected"
    And the booking status should be "rejected"

  Scenario: Admin sees only pending bookings for approval-required rooms
    Given a room "Auto Room" exists with requires_approval false
    And a room "Manual Room" exists with requires_approval true
    And a booking exists for "Auto Room" with status "confirmed"
    And a booking exists for "Manual Room" with status "pending"
    When I visit the admin bookings page
    And I filter by "Pending"
    Then I should see the "Manual Room" booking
    But I should not see the "Auto Room" booking