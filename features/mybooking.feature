Feature: My Bookings
  As a student
  I want to view and manage my bookings with cost information

  Background:
    Given a department "UC" exists
    And a room "Room A" exists in "UC" with price_per_unit 0.00
    And a room "Premium Room" exists in "UC" with price_per_unit 150.00
    And an equipment "Projector" exists in "UC" with price_per_unit 100.00
    And an equipment "Free Mic" exists in "UC" with price_per_unit 0.00
    And I am logged in as a student

  Scenario: View my bookings with cost
    Given I have the following bookings:
      | resource      | date     | start | end   | status    | total_cost |
      | Room A        | tomorrow | 10:00 | 12:00 | confirmed | 0.00       |
      | Premium Room  | tomorrow | 14:00 | 16:00 | pending   | 600.00     |
      | Projector     | tomorrow | 09:00 | 11:00 | confirmed | 400.00     |
    When I visit my bookings page
    Then I should see "Room A" with cost "Free"
    And I should see "Premium Room" with cost "$600.00"
    And I should see "Projector" with cost "$400.00"

  Scenario: Bookings separated by tabs (Rooms / Equipment)
    Given I have the following bookings:
      | resource  | date     | start | end   | status    |
      | Room A    | tomorrow | 10:00 | 12:00 | confirmed |
      | Projector | tomorrow | 14:00 | 16:00 | confirmed |
    When I visit my bookings page
    And I click "Rooms"
    Then I should see "Room A"
    But I should not see "Projector"
    When I click "Equipment"
    Then I should see "Projector"
    But I should not see "Room A"

  Scenario: See booking details with cost breakdown
    Given I have a confirmed booking for "Premium Room" tomorrow "10:00"-"12:00"
    When I visit my bookings page
    And I click on the booking
    Then I should see the booking details:
      | Resource        | Premium Room  |
      | Date            | tomorrow      |
      | Time            | 10:00–12:00   |
      | Duration        | 2 hours       |
      | Price per slot  | $150.00       |
      | Number of slots | 4             |
      | Total cost      | $600.00       |
      | Status          | Confirmed     |

  Scenario: See pending status with cost
    Given I have a pending booking for "Premium Room" tomorrow "10:00"-"12:00"
    When I visit my bookings page
    Then I should see "Pending Approval"
    And I should see "Total cost: $600.00"

  Scenario: See rejection reason
    Given I have a rejected booking for "Room A" with reason "Under maintenance"
    When I visit my bookings page
    Then I should see "Rejected"
    And I should see "Under maintenance"

  Scenario: Calculate total spending
    Given I have the following bookings:
      | resource      | date     | start | end   | status    | total_cost |
      | Premium Room  | tomorrow | 10:00 | 12:00 | confirmed | 600.00     |
      | Projector     | tomorrow | 14:00 | 16:00 | confirmed | 400.00     |
      | Free Mic      | tomorrow | 09:00 | 10:00 | confirmed | 0.00       |
    When I visit my bookings page
    Then I should see "Total spending: $1,000.00"

  Scenario: No bookings yet
    When I visit my bookings page
    Then I should see "No bookings yet"

  Scenario: Bookings ordered by date (newest first)
    Given I have the following bookings:
      | resource | date            | start | end   | status    |
      | Room A   | 3 days from now | 10:00 | 12:00 | confirmed |
      | Room A   | tomorrow        | 14:00 | 16:00 | confirmed |
    When I visit my bookings page
    Then "3 days from now" should appear before "tomorrow"