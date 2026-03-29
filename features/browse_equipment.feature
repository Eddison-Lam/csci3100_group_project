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
      | name             | department | quantity | equipment_type  | price_per_unit |
      | Portable PA      | UC         | 3        | Audio Equipment | 0.00           |
      | Projector        | NA         | 5        | AV Equipment    | 100.00         |
      | Wireless Mic Set | UC         | 2        | Audio Equipment | 50.00          |
      | 攝影機           | NA         | 2        | 攝影器材        | 200.00         |
      | Lighting Kit     | UC         | 1        | Lighting        | 150.00         |
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
    When I visit the equipment page for "today"
    Then the equipment "Lighting Kit" should show "Unavailable"
    And I should not be able to book "Lighting Kit"

  Scenario: Select slots for paid equipment shows total cost
    When I visit the equipment page for "tomorrow"
    And I select slots from "10:00" to "14:00" for "Projector"
    Then I should see the booking summary for "Projector":
      | time     | 10:00 – 14:00 |
      | duration | 4 hours       |
      | slots    | 8             |
      | cost     | $800.00       |

  Scenario: Equipment pricing in confirmation
    When I visit the equipment page for "tomorrow"
    And I select slots from "09:00" to "12:00" for "攝影機"
    And I click "Book This Equipment"
    Then I should see the booking cost breakdown:
      | Equipment       | 攝影機      |
      | Date            | tomorrow    |
      | Time            | 09:00 – 12:00 |
      | Duration        | 3 hours     |
      | Price per slot  | $200.00     |
      | Number of slots | 6           |
      | Total cost      | $1,200.00   |

  Scenario: Inactive equipment is hidden
    Given the equipment "Portable PA" is inactive
    When I visit the equipment page
    Then I should not see the "Portable PA"