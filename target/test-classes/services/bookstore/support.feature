# language: en
# encoding UTF-8

Feature: Support

  Background:
    * configure headers = { 'accept': 'application/json' }
    * url 'https://bookstore.toolsqa.com'

  @ReadAndGenerateTestData
  Scenario: Read and generate test data successfully
    * print '************ BEFORE FEATURE BEGIN ************'

    #Reading json data file
    * def data_accounts = read('classpath:services/bookstore/data/scenarios/accounts.json')

    #Generating invalid account 1
    * def invalid_account_1_res = call read('classpath:services/bookstore/support.feature@CreateAccountBookstore') { username: #(data_accounts.invalid_account_1.username), password: #(data_accounts.invalid_account_1.password) }
    * set data_accounts.invalid_account_1.userId = invalid_account_1_res.userID
    * match data_accounts.invalid_account_1.userId == invalid_account_1_res.userID

    #Generating token invalid account 1
    * def tk_invalid_account_1_res = call read('classpath:services/bookstore/support.feature@GenerateTokenBookstore') { username: #(data_accounts.invalid_account_1.username), password: #(data_accounts.invalid_account_1.password) }
    * set data_accounts.invalid_account_1.token = tk_invalid_account_1_res.token
    * match data_accounts.invalid_account_1.token == tk_invalid_account_1_res.token

    * print '************ BEFORE FEATURE END ************'

  @CreateAccountBookstore
  Scenario: Create account test data successfully
    * def body = read('classpath:services/bookstore/data/payload/account.json')
    Given path '/Account/v1/User'
    And header Content-Type = 'application/json'
    And request body
    When method post
    Then status 201
    * def userID = response.userID

  @GenerateTokenBookstore
  Scenario: Generate account token test data successfully
    * def body = read('classpath:services/bookstore/data/payload/account.json')
    Given path '/Account/v1/GenerateToken'
    And header Content-Type = 'application/json'
    And request body
    When method post
    Then status 200
    * def token = response.token

  @DeleteInvalidAccount1Bookstore
  Scenario: Delete invalid_account_1 test data successfully
    * print '************ AFTER FEATURE BEGIN ************'
    * def user_id = data_file.data_accounts.invalid_account_1.userId
    * def token = data_file.data_accounts.invalid_account_1.token
    Given path '/Account/v1/User', user_id
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + token
    When method delete
    Then status 204
    * print '************ AFTER FEATURE END ************'