Feature: Authentication
  CUHK members can register and login with their CUHK email

# Registration

Scenario: Visit home page without login shows registration prompt
    When I go to the home page
    Then I should see "CUHK Venue & Equipment Booking"
    And I should see "Please log in to access the booking system"
    And I should see "Register"
    And I should see "Login"

Scenario: Student registers with link.cuhk.edu.hk email
  Given I am on the registration page
  When I fill in the following:
    | Email                 | 1155123456@link.cuhk.edu.hk |
    | Password              | password123                  |
    | Password confirmation | password123                  |
  And I click "Sign up"
  Then I should see "Welcome"
  And my role should be "student"

Scenario: Staff registers with cuhk.edu.hk email automatically becomes admin
    Given I am on the registration page
    When I fill in the following:
      | Email                 | wong@cse.cuhk.edu.hk |
      | Password              | password123      |
      | Password confirmation | password123      |
    And I click "Sign up"
    Then my role should be "admin"

Scenario: Rejected with non-CUHK email
    Given I am on the registration page
    When I fill in the following:
      | Email                 | hacker@gmail.com |
      | Password              | password123      |
      | Password confirmation | password123      |
    And I click "Sign up"
    Then I should see "Must be a valid CUHK email"

Scenario: Rejected with invalid password
    Given I am on the registration page
    When I fill in the following:
      | Email                 | test@link.cuhk.edu.hk       |
      | Password              | short                       |
      | Password confirmation | short                       |
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
    Then I should see "Welcome"
    And I should see "Book a Room"

Scenario: Admin logs in successfully
    Given an activated admin "ucadmin@uc.cuhk.edu.hk" exists in department "UC"
    And I am on the login page
    When I fill in the following:
      | Email    | ucadmin@uc.cuhk.edu.hk |
      | Password | password123         |
    And I click "Log in"
    Then I should see "Dept: UC"

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

Scenario: User logs out
    Given a student "1155123456@link.cuhk.edu.hk" exists
    And I am on the login page
    When I fill in the following:
      | Email    | 1155123456@link.cuhk.edu.hk |
      | Password | password123                 |
    And I click "Log in"
    Then I should see "Log Out"
    When I click "Log Out"
    Then I should be on the home page
    And I should see "Signed out successfully"