Feature: Stripe Payment (Mock)      #default lock timeout is 5 minutes, stored in settings table
  As a student
  I want to pay for paid rooms/equipment during confirmation
  So that booking only completes after successful payment

  Background:
    Given a paid room "VIP Room" exists with price_per_unit 300.00
    And a paid equipment "Projector" exists with price_per_unit 100.00
    And Stripe mock mode is enabled
    And I am logged in as a student
