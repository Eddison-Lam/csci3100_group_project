# optional
Feature: Cancel Booking
  As a student
  I want to cancel my bookings
  So that the slot becomes available for others

  Background:
    Given a department "UC" exists
    And a room "Room A" exists in "UC" with price_per_unit 100.00
    And I am logged in as a student

  Scenario: Cancel a confirmed booking
    Given I have a confirmed booking for "Room A" tomorrow "10:00"-"12:00"
    When I visit my bookings page
    And I click "Cancel" for that booking
    Then I should see "Booking cancelled"
    And the booking status should be "cancelled"

  Scenario: Cancel a pending booking
    Given I have a pending booking for "Room A" tomorrow "10:00"-"12:00"
    When I visit my bookings page
    And I click "Cancel" for that booking
    Then I should see "Booking cancelled"
    And the booking status should be "cancelled"

  Scenario: Cannot cancel already cancelled booking
    Given I have a cancelled booking for "Room A"
    When I visit my bookings page
    Then I should not see "Cancel" button for that booking

  Scenario: Cannot cancel rejected booking
    Given I have a rejected booking for "Room A"
    When I visit my bookings page
    Then I should not see "Cancel" button for that booking

  Scenario: Cannot cancel past booking
    Given I have a confirmed booking for "Room A" on "yesterday" from "10:00" to "12:00"
    When I visit my bookings page
    Then I should not see "Cancel" button for that booking

  Scenario: Cancelled slot becomes available again
    Given I have a confirmed booking for "Room A" tomorrow "10:00"-"12:00"
    When I cancel that booking
    And another student visits the rooms page for "tomorrow"
    Then the slots from "10:00" to "12:00" for "Room A" should be available