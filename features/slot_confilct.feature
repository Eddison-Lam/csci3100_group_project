Feature: Slot Conflict Prevention
  The system prevents double-booking through UI blocking and temporary locks

  Background:
    Given a department "UC" exists
    And a room "Room X" exists in "UC" with:
      | requires_approval | false |
      | price_per_unit    | 0.00  |
    And the booking lock timeout is 5 minutes
    And I am logged in as a student

  # Already Booked Slots - UI Level Blocking

  Scenario: Booked slots are disabled and cannot be selected
    Given a confirmed booking exists for "Room X" on "tomorrow" from "10:00" to "12:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "10:00" to "12:00" for "Room X" should show as "Booked"
    And the slots from "10:00" to "12:00" for "Room X" should be disabled
    And I should not be able to check the "10:00" slot for "Room X"
    And I should not be able to check the "10:30" slot for "Room X"
    And I should not be able to check the "11:00" slot for "Room X"
    And I should not be able to check the "11:30" slot for "Room X"

  Scenario: Can only select slots around booked slots
    Given a confirmed booking exists for "Room X" on "tomorrow" from "10:00" to "12:00"
    When I visit the rooms page for "tomorrow"
    Then I should be able to check the "09:30" slot for "Room X"
    And I should be able to check the "12:00" slot for "Room X"
    And I should be able to check the "12:30" slot for "Room X"

  Scenario: Pending bookings also show as booked
    Given a pending booking exists for "Room X" on "tomorrow" from "14:00" to "15:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "14:00" to "15:00" for "Room X" should show as "Booked"
    And the slots from "14:00" to "15:00" for "Room X" should be disabled

  Scenario: Cancelled bookings do not block slots
    Given a cancelled booking exists for "Room X" on "tomorrow" from "16:00" to "17:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "16:00" to "17:00" for "Room X" should show as "Available"
    And I should be able to check the "16:00" slot for "Room X"

  Scenario: Rejected bookings do not block slots
    Given a rejected booking exists for "Room X" on "tomorrow" from "18:00" to "19:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "18:00" to "19:00" for "Room X" should show as "Available"
    And I should be able to check the "18:00" slot for "Room X"

  # Temporary Lock System

  Scenario: Clicking "Book This Room" creates a temporary lock
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "Room X"
    And I click "Book This Room" for "Room X"
    Then a temporary lock should be created for "Room X" slots "10:00" to "12:00"
    And the lock should expire in 5 minutes

  Scenario: Other users see locked slots as unavailable
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    And the slots are locked by me
    When another student visits the rooms page for "tomorrow"
    Then they should see the slots from "10:00" to "12:00" for "Room X" as "In Progress"
    And the slots from "10:00" to "12:00" for "Room X" should be disabled for them

  Scenario: Lock expires after timeout period
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    And the slots are locked by me
    When 5 minutes have passed
    And another user visits the rooms page for "tomorrow"
    Then the slots from "10:00" to "12:00" for "Room X" should show as "Available"
    And they should be able to check the "10:00" slot for "Room X"

  Scenario: User is kicked back if lock expires before submission
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    And the slots are locked by me
    When 5 minutes have passed
    And I fill in "Purpose" with "My meeting"
    And I click "Confirm Booking"
    Then I should see "Your booking session has expired. Please select the time slots again."
    And I should be redirected to the rooms page
    And no booking should be created

  Scenario: Lock is released when user cancels
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    And the slots are locked by me
    When I click "Cancel"
    Then the lock should be released
    And other users should see those slots as available

  Scenario: Lock is released when booking is confirmed
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    And the slots are locked by me
    When I fill in "Purpose" with "Meeting"
    And I click "Confirm Booking"
    Then the lock should be released
    And a confirmed booking should exist for those slots

  # Race Condition - Two Users Try to Book Same Slots

  Scenario: First user to click confirm gets the lock
    Given User A selects slots from "10:00" to "12:00" for "Room X" tomorrow
    And User B selects the same slots
    When User A clicks "Book This Room"
    Then User A should see the booking confirmation page
    And a lock should be created for User A
    When User B clicks "Book This Room"
    Then User B should see "These slots are currently being booked by another user"
    And User B should be redirected to the rooms page

  Scenario: Second user can proceed after first user's lock expires
    Given User A is on the confirmation page with a lock on "10:00"-"12:00"
    And 5 minutes have passed
    When User B selects slots from "10:00" to "12:00" for "Room X"
    And User B clicks "Book This Room"
    Then User B should see the booking confirmation page
    And a new lock should be created for User B

  Scenario: Second user can proceed after first user completes booking
    Given User A is on the confirmation page with a lock on "10:00"-"12:00"
    When User A confirms the booking
    Then the slots from "10:00" to "12:00" for "Room X" should show as "Booked"
    When User B visits the rooms page
    Then the slots from "10:00" to "12:00" should be disabled for User B

  # Final Submission Validation

  Scenario: System validates lock ownership before creating booking
    Given User A has a lock on "Room X" slots "10:00"-"12:00"
    When User A submits the booking
    Then the system should verify User A owns the lock
    And the booking should be created

  Scenario: Cannot submit if lock was stolen (edge case)
    Given User A has a lock on "Room X" slots "10:00"-"12:00"
    And the lock expires
    And User B acquires a new lock on the same slots
    When User A tries to submit the booking
    Then User A should see "Your booking session has expired"
    And no booking should be created for User A

  Scenario: Pessimistic database lock prevents final race condition
    Given User A and User B both have valid locks for different overlapping time ranges
    When both users submit their bookings simultaneously
    Then only one booking should succeed
    And the other should see "Time slot conflicts with existing booking"

  # Multiple Concurrent Users

  Scenario: Different users can lock different time slots simultaneously
    Given User A locks "Room X" slots "10:00"-"12:00"
    When User B selects slots "14:00"-"16:00" for "Room X"
    And User B clicks "Book This Room"
    Then User B should see the booking confirmation page
    And both locks should be active

  Scenario: Page refreshes show updated slot availability
    Given a confirmed booking exists for "Room X" on "tomorrow" from "10:00" to "11:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "10:00" to "11:00" should be disabled
    When another user books slots from "11:00" to "12:00"
    And I refresh the page
    Then the slots from "11:00" to "12:00" for "Room X" should be disabled

  # Lock Visibility

  Scenario: User sees their own lock as selected
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    When I go back to the rooms page
    Then I should still see my lock on those slots
    And I should see "You have 4 minutes remaining to complete this booking"

  Scenario: Lock countdown timer shown to user
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    Then I should see "Complete your booking within 5 minutes"
    When 2 minutes pass
    Then I should see "Complete your booking within 3 minutes"

  Scenario: Warning when lock is about to expire
    Given I am on the booking confirmation page for "Room X" tomorrow "10:00"-"12:00"
    When 4 minutes have passed
    Then I should see a warning "Your booking session will expire in 1 minute"