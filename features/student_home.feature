Feature: Student Home Page
  As a student
  I see navigation options to browse rooms, equipment, and my bookings

 Background:
    Given I am logged in as a student

Scenario: Student sees main navigation options
    Then I should see "Browse Rooms"
    And I should see "Browse Equipment"
    And I should see "My Bookings"

Scenario: Navigate to rooms page
    When I click "Browse Rooms"
    Then I should be on the rooms page

Scenario: Navigate to equipment page
    When I click "Browse Equipment"
    Then I should be on the equipment page

Scenario: Navigate to my bookings page
    When I click "My Bookings"
    Then I should be on the my bookings page

Scenario: Student does not see admin links
    Then I should not see the admin home page
    And I should not see "Manage Users"