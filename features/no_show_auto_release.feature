Feature: No-show and Auto-release
  As a department admin
  I want the system to automatically release no-show bookings
  So that slots become available for other student

  Background:
    Given a department "UC" exists
    And a room "Room A" exists in "UC" with price_per_unit 0.00
    And the no-show grace period is 15 minutes before start time
    And I am logged in as a student

  Scenario: Booking auto-releases if no-show after start time
    Given I have a confirmed booking for "Room A" tomorrow "10:00"-"11:00"
    When the current time passes "10:15" tomorrow
    And the auto-release job runs
    Then the booking status should be "no_show"
    And the slots from "10:00" to "11:00" for "Room A" should be available again

  Scenario: Booking remains confirmed if student checks in before grace period
    Given I have a confirmed booking for "Room A" tomorrow "10:00"-"11:00"
    When the student checks in at "09:50" tomorrow
    And the auto-release job runs
    Then the booking status should remain "confirmed"

  Scenario: No-show email notification sent to student and admin
    Given I have a confirmed booking for "Room A" tomorrow "10:00"-"11:00"
    When the booking becomes no_show
    Then the student should receive "No-show detected" email
    And the department admin should receive a no-show alert

  Scenario: Paid booking still charges for no-show (penalty)
    Given a paid room "VIP Room" exists with price_per_unit 200.00
    And I have a confirmed booking for "VIP Room" tomorrow "10:00"-"11:00"
    When the booking becomes no_show
    Then the student is still charged "$200.00"
    And status is "no_show"
