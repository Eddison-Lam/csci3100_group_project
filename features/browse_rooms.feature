Feature: Browse Rooms
  As a student
  I want to browse and filter rooms and see pricing
  So that I can find and book a suitable room

  Background:
    Given the following departments exist:
      | name             | code |
      | United College   | UC   |
      | New Asia College | NA   |
    And the following rooms exist:
      | name          | department | building              | room_type    | location | capacity | price_per_unit |
      | UC Meeting A  | UC         | UC Amenities Building | Meeting Room | 2/F      | 30       | 0.00           |
      | UC Meeting B  | UC         | UC Amenities Building | Meeting Room | 3/F      | 20       | 50.00          |
      | UC Study Room | UC         | UC Library            | Study Room   | 3/F      | 8        | 0.00           |
      | NA Room       | NA         | NA Humanities Bldg    | Study Room   | 1/F      | 20       | 100.00         |
    And I am logged in as a student

  Scenario: See all rooms by default
    When I visit the rooms page
    Then I should see "UC Meeting A"
    And I should see "UC Meeting B"
    And I should see "UC Study Room"
    And I should see "NA Room"

  Scenario: Room card shows pricing
    When I visit the rooms page
    Then the room "UC Meeting A" should display "Free"
    And the room "UC Meeting B" should display "$50.0/slot"
    And the room "NA Room" should display "$100.0/slot"

  Scenario: Filter by building
    When I visit the rooms page
    And I select "UC Amenities Building" from "buildings[]"
    And I click "Search"
    Then I should see "UC Meeting A"
    And I should see "UC Meeting B"

  Scenario: Filter by capacity
    When I visit the rooms page
    And I fill in "capacity" with "20"
    And I click "Search"
    Then I should see "UC Meeting A"
    And I should see "UC Meeting B"
    And I should see "NA Room"

  Scenario: Navigate to next day
    When I visit the rooms page
    And I click "UC Meeting A"
    And I select date "tomorrow"
    Then I should see available slots
