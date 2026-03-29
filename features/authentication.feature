Feature: Authentication
  CUHK members can register and login with their CUHK email

# Registration

Scenario: Visit home page without login redirects to login
    When I go to the home page
    Then I should be on the login page

Scenario: Student registers with link.cuhk.edu.hk email
  Given I am on the registration page
  When I fill in the following:
    | Email                 | 1155123456@link.cuhk.edu.hk |
    | Password              | password123                  |
    | Password confirmation | password123                  |
  And I click "Sign up"
  Then I should see "Welcome"
  And my role should be "student"

Scenario: Staff registers with cuhk.edu.hk email (pending activation)
    Given I am on the registration page
    When I fill in the following:
      | Name                  | Dr. Wong         |
      | Email                 | wong@cuhk.edu.hk |
      | Password              | password123      |
      | Password confirmation | password123      |
    And I click "Sign up"
    Then I should see "Account pending activation"
    And my role should be "admin"
    And I should not have a department assigned

Scenario: Rejected with non-CUHK email
    Given I am on the registration page
    When I fill in the following:
      | Name                  | Hacker           |
      | Email                 | hacker@gmail.com |
      | Password              | password123      |
      | Password confirmation | password123      |
    And I click "Sign up"
    Then I should see "must be a CUHK email address"
    And I should not be signed in

Scenario: Rejected with invalid password
    Given I am on the registration page
    When I fill in the following:
      | Name                  | Test User                   |
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
    Then I should be on the student home page
    And I should see "Browse Rooms"

Scenario: Activated admin logs in successfully
    Given an activated admin "ucadmin@cuhk.edu.hk" exists in department "UC"
    And I am on the login page
    When I fill in the following:
      | Email    | ucadmin@cuhk.edu.hk |
      | Password | password123         |
    And I click "Log in"
    Then I should be on the admin home page

Scenario: Login with wrong password
    Given a student "1155123456@link.cuhk.edu.hk" exists
    And I am on the login page
    When I fill in the following:
      | Email    | 1155123456@link.cuhk.edu.hk |
      | Password | wrongpassword               |
    And I click "Log in"
    Then I should see "Invalid Email or password"
    And I should be on the login page

Scenario: Login with non-existent email
    Given I am on the login page
    When I fill in the following:
      | Email    | nobody@link.cuhk.edu.hk |
      | Password | password123             |
    And I click "Log in"
    Then I should see "Invalid Email or password"

Scenario: User logs out
    Given I am logged in as a student
    When I click "Sign out"
    Then I should be on the login page
    And I should see "Signed out successfully"