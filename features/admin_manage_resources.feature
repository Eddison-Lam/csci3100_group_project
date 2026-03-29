Feature: Admin Manage Resources
  As a department admin
  I want to manage my department's rooms and equipment with pricing

  Background:
    Given a department "UC" exists with an admin "ucadmin@cuhk.edu.hk"
    And I am logged in as admin "ucadmin@cuhk.edu.hk"

  Scenario: Create a free room
    When I visit the admin resources page
    And I click "New Resource"
    And I select "Room" from "Type"
    And I fill in the following:
      | Name           | New Meeting Room      |
      | Building       | UC Main Building      |
      | Room type      | Meeting Room          |
      | Location       | 3/F Room 301          |
      | Capacity       | 25                    |
      | Price per slot | 0.00                  |
    And I click "Create"
    Then I should see "Resource created"
    And I should see "New Meeting Room"
    And I should see "Free"

  Scenario: Create a paid room
    When I visit the admin resources page
    And I click "New Resource"
    And I select "Room" from "Type"
    And I fill in the following:
      | Name           | VIP Conference Room |
      | Building       | UC Main Building    |
      | Room type      | Conference Room     |
      | Location       | 5/F                 |
      | Capacity       | 20                  |
      | Price per slot | 250.00              |
    And I click "Create"
    Then I should see "Resource created"
    And I should see "$250.00 per slot"

  Scenario: Create free equipment
    When I visit the admin resources page
    And I click "New Resource"
    And I select "Equipment" from "Type"
    And I fill in the following:
      | Name           | Whiteboard Markers  |
      | Equipment type | Stationery          |
      | Quantity       | 10                  |
      | Price per slot | 0.00                |
    And I click "Create"
    Then I should see "Resource created"
    And I should see "Free"

  Scenario: Create paid equipment
    When I visit the admin resources page
    And I click "New Resource"
    And I select "Equipment" from "Type"
    And I fill in the following:
      | Name           | Professional Camera |
      | Equipment type | Photography         |
      | Quantity       | 2                   |
      | Price per slot | 300.00              |
    And I click "Create"
    Then I should see "Resource created"
    And I should see "$300.00 per slot"

  Scenario: Edit resource pricing
    Given a room "Budget Room" exists in "UC" with price_per_unit 50.00
    When I visit the admin resources page
    And I click "Edit" for "Budget Room"
    And I fill in "Price per slot" with "75.00"
    And I click "Update"
    Then I should see "Resource updated"
    And "Budget Room" should have price_per_unit 75.00

  Scenario: Change room from free to paid
    Given a room "Free Room" exists in "UC" with price_per_unit 0.00
    When I visit the admin resources page
    And I click "Edit" for "Free Room"
    And I fill in "Price per slot" with "100.00"
    And I click "Update"
    Then I should see "$100.00 per slot"

  Scenario: Change room from paid to free
    Given a room "Paid Room" exists in "UC" with price_per_unit 200.00
    When I visit the admin resources page
    And I click "Edit" for "Paid Room"
    And I fill in "Price per slot" with "0.00"
    And I click "Update"
    Then I should see "Free"

  Scenario: Cannot set negative price
    When I visit the admin resources page
    And I click "New Resource"
    And I select "Room" from "Type"
    And I fill in "Price per slot" with "-50.00"
    And I click "Create"
    Then I should see "Price per slot must be greater than or equal to 0"

  Scenario: Toggle requires_approval for existing room
    Given a room "Flexible Room" exists with requires_approval false
    When I visit the admin resources page
    And I click "Edit" for "Flexible Room"
    And I check "Requires approval"
    And I click "Update"
    Then "Flexible Room" should require approval
    And new bookings for "Flexible Room" should be pending

  Scenario: Create room with approval requirement
    When I visit the admin resources page
    And I click "New Resource"
    And I fill in the following:
        | Name | Controlled Room |
        | Type | Room            |
    And I check "Requires approval"
    And I click "Create"
    Then the room should be created with requires_approval true
