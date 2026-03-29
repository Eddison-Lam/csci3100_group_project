Feature: Browse Rooms
  As a student
  I want to search rooms with filters, view availability on calendar, and see pricing
  So that I can find and book a suitable room

  Background:
    Given the following departments exist:
      | name             | code |
      | United College   | UC   |
      | New Asia College | NA   |
    And the following rooms exist:
      | name            | department | building              | room_type    | location | capacity | max_slots_per_booking | price_per_unit |
      | UC Meeting A    | UC         | UC Amenities Building | Meeting Room | 2/F      | 30       | 8                     | 0.00           |
      | UC Meeting B    | UC         | UC Amenities Building | Meeting Room | 3/F      | 20       | 8                     | 50.00          |
      | UC Lecture Hall | UC         | UC Amenities Building | Lecture Hall | 1/F      | 100      | 4                     | 200.00         |
      | UC Study Room   | UC         | UC Library            | Study Room   | 3/F      | 8        | 4                     | 0.00           |
      | NA 研討室 101   | NA         | NA Humanities Bldg    | 研討室       | 1/F      | 20       | 6                     | 0.00           |
      | NA 活動室       | NA         | NA Humanities Bldg    | 活動室       | 2/F      | 50       | 8                     | 100.00         |
    And I am logged in as a student
    And today is "2026-03-15" which is a Sunday

  # CALENDAR & DATE SELECTION

  Scenario: Calendar is displayed on the side
    When I visit the rooms page
    Then I should see a calendar for the current month
    And today "March 15" should be highlighted on the calendar
    And past dates should be disabled on the calendar

  Scenario: Select a date from calendar
    When I visit the rooms page
    And I click "March 20" on the calendar
    Then the selected date should be "March 20, 2026"
    And I should see room availability for "March 20, 2026"

  Scenario: Navigate to next month on calendar
    When I visit the rooms page
    And I click "Next Month" on the calendar
    Then I should see the calendar for "April 2026"

  Scenario: Cannot select dates beyond advance booking limit
    Given the maximum advance booking days is 30
    When I visit the rooms page
    Then dates after "April 14, 2026" should be disabled on the calendar

  # VIEW MODE: 1 DAY

  Scenario: Default view is 1 Day
    When I visit the rooms page
    Then the view mode should be "1 Day"
    And I should see the date "March 15, 2026"
    And I should see all rooms with their time slots for that day

  Scenario: 1 Day view shows selected date
    When I visit the rooms page
    And I click "March 18" on the calendar
    Then I should see room availability for "March 18, 2026"
    And I should see slots from "08:00" to "22:00" for each room

  # VIEW MODE: WEEK

  Scenario: Week view requires selecting a specific facility
    When I visit the rooms page
    And I select "Week" from "View"
    And I have not selected a specific facility
    And I click "Search"
    Then I should see "Please select a specific facility for week view"

  Scenario: Week view shows Monday to Sunday of selected date's week
    Given today is "2026-03-15" which is a Sunday
    When I visit the rooms page
    And I select "Week" from "View"
    And I select "UC Meeting A" from "Facility"
    And I click "Search"
    Then I should see a weekly calendar for "UC Meeting A"
    And the week should show "March 9" to "March 15"

  Scenario: Week view - select date in middle of week shows that week
    When I visit the rooms page
    And I click "March 18" on the calendar
    And I select "Week" from "View"
    And I select "UC Meeting A" from "Facility"
    And I click "Search"
    Then the week should show "March 16" to "March 22"

  # FILTER: LOCATION (Multi-select)

  Scenario: See all rooms when no location selected
    When I visit the rooms page
    Then I should see all 6 rooms

  Scenario: Filter by single location
    When I visit the rooms page
    And I check "UC Library" under "Location"
    And I click "Search"
    Then I should see "UC Study Room"
    But I should not see the "UC Meeting A"
    And I should not see the "NA 研討室 101"

  Scenario: Filter by multiple locations
    When I visit the rooms page
    And I check "UC Amenities Building" under "Location"
    And I check "UC Library" under "Location"
    And I click "Search"
    Then I should see "UC Meeting A"
    And I should see "UC Lecture Hall"
    And I should see "UC Study Room"
    But I should not see the "NA 研討室 101"

  # FILTER: FACILITY TYPE (Cascading)

  Scenario: Facility Type shows all types when no location selected
    When I visit the rooms page
    Then the "Facility Type" filter should show:
      | Meeting Room |
      | Lecture Hall |
      | Study Room   |
      | 研討室       |
      | 活動室       |

  Scenario: Facility Type updates based on selected location
    When I visit the rooms page
    And I check "UC Amenities Building" under "Location"
    Then the "Facility Type" filter should only show:
      | Meeting Room |
      | Lecture Hall |

  Scenario: Filter by location then room type
    When I visit the rooms page
    And I check "UC Amenities Building" under "Location"
    And I check "Meeting Room" under "Facility Type"
    And I click "Search"
    Then I should see "UC Meeting A"
    And I should see "UC Meeting B"
    But I should not see the "UC Lecture Hall"

  # FILTER: CAPACITY

  Scenario: Filter by minimum capacity
    When I visit the rooms page
    And I fill in "Capacity" with "25"
    And I click "Search"
    Then I should see "UC Meeting A"
    And I should see "UC Lecture Hall"
    And I should see "NA 活動室"
    But I should not see the "UC Study Room"

  # FILTER: PRICE

  Scenario: Filter to show only free rooms
    When I visit the rooms page
    And I check "Free only" under "Price"
    And I click "Search"
    Then I should see "UC Meeting A"
    And I should see "UC Study Room"
    And I should see "NA 研討室 101"
    But I should not see the "UC Meeting B"
    And I should not see the "UC Lecture Hall"
    And I should not see the "NA 活動室"

  Scenario: Filter by maximum price per slot
    When I visit the rooms page
    And I fill in "Max price per slot" with "100"
    And I click "Search"
    Then I should see "UC Meeting A"
    And I should see "UC Meeting B"
    And I should see "UC Study Room"
    And I should see "NA 活動室"
    But I should not see the "UC Lecture Hall"

  # ROOM INFORMATION DISPLAY

  Scenario: Room card shows pricing information
    When I visit the rooms page
    Then the room "UC Meeting A" should display "Free"
    And the room "UC Meeting B" should display "$50.00 per slot"
    And the room "UC Lecture Hall" should display "$200.00 per slot"

  Scenario: Room card shows all key information
    When I visit the rooms page
    Then the room card for "UC Meeting A" should show:
      | name       | UC Meeting A          |
      | building   | UC Amenities Building |
      | location   | 2/F                   |
      | type       | Meeting Room          |
      | capacity   | 30                    |
      | hours      | 08:00 – 22:00         |
      | max_booking| 4 hours               |
      | price      | Free                  |

  # SLOT DISPLAY & AVAILABILITY

  Scenario: Booked slots shown as disabled
    Given a confirmed booking exists for "UC Meeting A" on "tomorrow" from "10:00" to "12:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "10:00" to "12:00" for "UC Meeting A" should show as "Booked"
    And the slots from "10:00" to "12:00" for "UC Meeting A" should be disabled

  Scenario: Pending bookings also block slots
    Given a pending booking exists for "UC Meeting A" on "tomorrow" from "14:00" to "15:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "14:00" to "15:00" for "UC Meeting A" should be disabled

  Scenario: Cancelled bookings do not block slots
    Given a cancelled booking exists for "UC Meeting A" on "tomorrow" from "16:00" to "17:00"
    When I visit the rooms page for "tomorrow"
    Then the slots from "16:00" to "17:00" for "UC Meeting A" should be enabled

  # SLOT SELECTION & PRICING CALCULATION

  Scenario: Select slots for free room shows no cost
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "UC Meeting A"
    Then I should see the booking summary for "UC Meeting A":
      | time     | 10:00 – 12:00 |
      | duration | 2 hours       |
      | cost     | Free          |

  Scenario: Select slots for paid room shows total cost
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "UC Meeting B"
    Then I should see the booking summary for "UC Meeting B":
      | time     | 10:00 – 12:00 |
      | duration | 2 hours       |
      | slots    | 4             |
      | cost     | $200.00       |

  Scenario: Cost updates when selecting more slots
    When I visit the rooms page for "tomorrow"
    And I check the "10:00" slot for "UC Meeting B"
    Then I should see the cost "$50.00" for "UC Meeting B"
    When I check the "10:30" slot for "UC Meeting B"
    Then I should see the cost "$100.00" for "UC Meeting B"
    When I check the "11:00" slot for "UC Meeting B"
    Then I should see the cost "$150.00" for "UC Meeting B"

  Scenario: Deselecting slots updates cost
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "UC Lecture Hall"
    Then I should see the cost "$800.00" for "UC Lecture Hall"
    When I uncheck the "11:30" slot for "UC Lecture Hall"
    Then I should see the cost "$600.00" for "UC Lecture Hall"

  # SLOT VALIDATION

  Scenario: Cannot select non-consecutive slots
    When I visit the rooms page for "tomorrow"
    And I check the "10:00" slot for "UC Meeting A"
    And I check the "12:00" slot for "UC Meeting A"
    Then I should see the error "Please select consecutive slots" for "UC Meeting A"
    And the "Book This Room" button should be disabled for "UC Meeting A"

  Scenario: Cannot exceed maximum duration
    Given "UC Lecture Hall" has max_slots_per_booking of 4
    When I visit the rooms page for "tomorrow"
    And I try to select 5 consecutive slots for "UC Lecture Hall"
    Then I should see the error "Maximum 2 hours for this room" for "UC Lecture Hall"
    And the "Book This Room" button should be disabled for "UC Lecture Hall"

  # BOOKING CONFIRMATION

  Scenario: Proceed to booking confirmation shows cost
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "12:00" for "UC Lecture Hall"
    And I click "Book This Room" for "UC Lecture Hall"
    Then I should be on the booking confirmation page
    And I should see the booking cost breakdown:
      | Room                  | UC Lecture Hall |
      | Date                  | tomorrow        |
      | Time                  | 10:00 – 12:00   |
      | Duration              | 2 hours         |
      | Price per slot        | $200.00         |
      | Number of slots       | 4               |
      | Total cost            | $800.00         |

  Scenario: Confirmation for free room shows no cost
    When I visit the rooms page for "tomorrow"
    And I select slots from "10:00" to "11:00" for "UC Study Room"
    And I click "Book This Room" for "UC Study Room"
    Then I should see "Total cost: Free"

  # Need approval? 
  
  Scenario: Room requiring approval shows indicator
  Given a room "VIP Room" exists with requires_approval true
  When I visit the rooms page
  Then the room "VIP Room" should show "⏳ Requires Approval"

  Scenario: Room not requiring approval shows auto-confirm    
  Given a room "Study Room" exists with requires_approval false
  When I visit the rooms page
  Then the room "Study Room" should show "✓ Auto-confirmed"

  # INACTIVE ROOMS

  Scenario: Inactive rooms are hidden
    Given the room "UC Meeting A" is inactive
    When I visit the rooms page
    Then I should not see the "UC Meeting A"

  # NO RESULTS

  Scenario: No results found
    When I visit the rooms page
    And I fill in "Capacity" with "500"
    And I click "Search"
    Then I should see "No rooms found"