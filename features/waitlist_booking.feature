Feature: Waitlist for Full Slots
  As a student
  I want to join waitlist when slot is full
  So that I get notified if someone cancels

  Background:
    Given a room "Room A" exists
    And all slots "10:00"-"12:00" tomorrow are fully booked
    And I am logged in as a student