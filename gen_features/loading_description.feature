Feature: Loading description


  Scenario: Loading the description of a number.
    Given There are no descriptions cached.
    When We load the description for number 5.
    Then The description of number 5 is loaded and cached.

  Scenario: Loading the description of two numbers.
    Given There are no descriptions cached.
    When We load the description for number 20, and then for number 5.
    Then The descriptions of numbers 5 and 20 are loaded and cached.

  Scenario: Clearing the cache of descriptions.
    Given There are descriptions cached.
    When We clear the cache.
    Then The cache is empty.
