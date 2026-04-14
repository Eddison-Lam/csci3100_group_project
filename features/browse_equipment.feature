Feature: Browse Equipment
  As a student
  I want to browse and filter available equipment with pricing
  So that I can find equipment to borrow

  Background:
    Given the following departments exist:
      | name             | code |
      | United College   | UC   |
      | New Asia College | NA   |
    And the following equipment exists:
      | name                         | department | quantity | price_per_unit |
      | Portable PA                  | UC         | 3        | 0.00           |
      | Projector                    | NA         | 5        | 100.00         |
      | Wireless Mic Set             | UC         | 2        | 50.00          |
      | 攝影機                         | NA         | 2        | 200.00         |
      | Lighting Kit                 | UC         | 1        | 150.00         |
      | Laptop (MacBook Pro)         | UC         | 20       | 0.00           |
      | 3D Printer (Ultimaker S5)    | NA         | 3        | 200.00         |
      | LED Light Panel Set          | UC         | 8        | 50.00          |
    And I am logged in as a student

  Scenario: See all active equipment by default
    When I visit the equipment page
    Then I should see "Portable PA"
    And I should see "Projector"
    And I should see "Wireless Mic Set"
    And I should see "攝影機"

  Scenario: Equipment card shows pricing
    When I visit the equipment page
    Then I should see "Laptop (MacBook Pro)"
    And I should see "Free"
    And I should see "3D Printer (Ultimaker S5)"
    And I should see "$200.0/slot"
    And I should see "攝影機"

  Scenario: Equipment card shows quantity available
    When I visit the equipment page
    Then I should see "Laptop (MacBook Pro)"
    And I should see "Quantity: 20"
    And I should see "3D Printer (Ultimaker S5)"
    And I should see "LED Light Panel Set"

  Scenario: Inactive equipment is hidden
    Given the equipment "Portable PA" is inactive
    When I visit the equipment page
    Then I should not see "Portable PA"