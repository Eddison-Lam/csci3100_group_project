Feature: Authentication
  CUHK members can register and login with their CUHK email

# Registration

Scenario: Visit home page without login shows registration prompt
    When I go to the home page
    Then I should see "CUHK Venue & Equipment Booking"
    And I should see "Please log in to access the booking system"
    And I should see "Register"
    And I should see "Login"

Scenario: Rejected with non-CUHK email
    Given I am on the registration page
    When I fill in the following:
      | Email                 | hacker@gmail.com |
      | Password              | password123      |
      | Password confirmation | password123      |
    And I click "Sign up"
    Then I should see "Must be a CUHK email address"

Scenario: Rejected with invalid password
    Given I am on the registration page
    When I fill in the following:
      | Email                 | testuser@link.cuhk.edu.hk |
      | Password              | short                      |
      | Password confirmation | short                      |
    And I click "Sign up"
    Then I should see "Password is too short"

# Login

Scenario: Student logs in successfully
    Given a student "1155123456@link.cuhk.edu.hk" exists
    And I am on the login page
    When I fill in the following:
      | Email    | 1155123456@link.cuhk.edu.hk |
      | Password | password123                 |
    And I click "Log in"
    Then I should see "Book a Room"

Scenario: Login with wrong password
    Given a student "1155123456@link.cuhk.edu.hk" exists
    And I am on the login page
    When I fill in the following:
      | Email    | 1155123456@link.cuhk.edu.hk |
      | Password | wrongpassword               |
    And I click "Log in"
    Then I should see "Invalid email or password"
    And I should be on the login page

Scenario: Login with non-existent email
    Given I am on the login page
    When I fill in the following:
      | Email    | nobody@link.cuhk.edu.hk |
      | Password | password123             |
    And I click "Log in"
    Then I should see "Invalid email or password"

Scenario: User can access home page when logged in
    Given I am logged in as a student
    When I visit the rooms page
    Then I should see "Book a Room"