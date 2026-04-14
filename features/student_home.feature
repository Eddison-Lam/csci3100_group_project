Feature: Student Home Page
  As a student
  I see navigation options to browse rooms, equipment, and my bookings

 Background:
    Given I am logged in as a student

Scenario: Student sees main navigation options
    Then I should see "Book a Room"
    And I should see "Home"
    And I should see "Book Equipment"
    And I should see "My Bookings"

Scenario: Navigate to rooms page
    When I click "Book a Room"
    Then I should be on the rooms page

Scenario: Navigate to equipment page
    When I click "Book Equipment"
    Then I should be on the equipment page

Scenario: Navigate to my bookings page
    When I click "My Bookings"
    Then I should be on the my bookings page

Scenario: Student does not see admin links
    Then I should not see "Admin"
    And I should not see "Manage Users"