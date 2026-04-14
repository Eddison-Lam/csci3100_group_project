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
      | name             | department | quantity | price_per_unit |
      | Portable PA      | UC         | 3        | 0.00           |
      | Projector        | NA         | 5        | 100.00         |
      | Wireless Mic Set | UC         | 2        | 50.00          |
      | 攝影機            | NA         | 2       | 200.00         |
      | Lighting Kit     | UC         | 1        | 150.00         |
    And I am logged in as a student

  Scenario: See all active equipment by default
    When I visit the equipment page
    Then I should see "Portable PA"
    And I should see "Projector"
    And I should see "Wireless Mic Set"
    And I should see "攝影機"

  Scenario: Filter by department
    When I visit the equipment page
    And I select "United College" from "College"
    And I click "Search"
    Then I should see "Portable PA"
    And I should see "Wireless Mic Set"
    But I should not see the "Projector"

  Scenario: Filter by equipment type
    When I visit the equipment page
    And I select "Audio Equipment" from "Equipment Type"
    And I click "Search"
    Then I should see "Portable PA"
    And I should see "Wireless Mic Set"
    But I should not see the "Projector"

  Scenario: Filter to show only free equipment
    When I visit the equipment page
    And I check "Free only" under "Price"
    And I click "Search"
    Then I should see "Portable PA"
    But I should not see the "Projector"
    And I should not see the "Wireless Mic Set"
    And I should not see the "攝影機"

  Scenario: Filter by maximum price
    When I visit the equipment page
    And I fill in "Max price per slot" with "100"
    And I click "Search"
    Then I should see "Portable PA"
    And I should see "Wireless Mic Set"
    And I should see "Projector"
    But I should not see the "攝影機"

  Scenario: Equipment card shows pricing
    When I visit the equipment page
    Then the equipment "Portable PA" should display "Free"
    And the equipment "Projector" should display "$100.00 per slot"
    And the equipment "攝影機" should display "$200.00 per slot"

  Scenario: Equipment card shows quantity available
    When I visit the equipment page
    Then I should see "Available: 3" for "Portable PA"
    And I should see "Available: 5" for "Projector"
    And I should see "Available: 1" for "Lighting Kit"

  Scenario: Equipment with 0 quantity shows unavailable
    Given the equipment "Lighting Kit" has 0 available quantity today
    When I visit the equipment page
    Then the equipment "Lighting Kit" should show "Unavailable"

  Scenario: Inactive equipment is hidden
    Given the equipment "Portable PA" is inactive
    When I visit the equipment page
    Then I should not see "Portable PA"