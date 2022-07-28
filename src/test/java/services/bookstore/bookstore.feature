# language: en
# encoding UTF-8

Feature: Book Store

  Background:
    * url 'https://bookstore.toolsqa.com'
    * configure headers = { 'accept': 'application/json' }
    * configure afterFeature = function(){ karate.call('classpath:services/bookstore/support.feature@DeleteInvalidAccount1Bookstore'); }

  @CreateAccountSuccessfully
  Scenario: CY001 - Create account successfully
    * def username = data_file.data_accounts.valid_account_1.username
    * def password = data_file.data_accounts.valid_account_1.password
    * def body = read('classpath:services/bookstore/data/payload/account.json')
    Given path '/Account/v1/User'
    And header Content-Type = 'application/json'
    And request body
    When method post
    Then status 201
    * set data_file.data_accounts.valid_account_1.userId = response.userID
    * match data_file.data_accounts.valid_account_1.userId == response.userID
    * print 'Created UserId is: ', response.userID
    * print 'User Data: ', data_file.data_accounts.valid_account_1

  @CreateAccountError
  Scenario: CY002 - Error creating account for existing account
    * def username = data_file.data_accounts.valid_account_1.username
    * def password = data_file.data_accounts.valid_account_1.password
    * def body = read('classpath:services/bookstore/data/payload/account.json')
    Given path '/Account/v1/User'
    And header Content-Type = 'application/json'
    And request body
    When method post
    Then status 406
    And match response contains { code: '1204', message: 'User exists!'}

  @GenerateTokenSuccessfully
  Scenario: CY003 - Generate account token successfully
    * def username = data_file.data_accounts.valid_account_1.username
    * def password = data_file.data_accounts.valid_account_1.password
    * def body = read('classpath:services/bookstore/data/payload/account.json')
    Given path '/Account/v1/GenerateToken'
    And header Content-Type = 'application/json'
    And request body
    When method post
    Then status 200
    And match response contains { token: '#notnull', expires: '#string', status: 'Success', result: 'User authorized successfully.'}
    * set data_file.data_accounts.valid_account_1.token = response.token
    * match data_file.data_accounts.valid_account_1.token == response.token
    * print 'Generated token is: ', response.token
    * print 'User Data: ', data_file.data_accounts.valid_account_1

  @AccountAuthorizedSuccessfully
  Scenario: CY004 - Account authorized successfully
    * def username = data_file.data_accounts.valid_account_1.username
    * def password = data_file.data_accounts.valid_account_1.password
    * def body = read('classpath:services/bookstore/data/payload/account.json')
    Given path '/Account/v1/Authorized'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + data_file.data_accounts.valid_account_1.token
    And request body
    When method post
    Then status 200

  @AccountNotAuthorized
  Scenario: CY005 - Account not authorized for reason 'Not Found'
    * def username = data_file.data_accounts.invalid_account_1.username
    * def password = 'invalidPass123'
    * def body = read('classpath:services/bookstore/data/payload/account.json')
    Given path '/Account/v1/Authorized'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + data_file.data_accounts.valid_account_1.token
    And request body
    When method post
    Then status 404
    And match response contains { code: '1207', message: 'User not found!'}

  @ConsultAccountSuccessfully
  Scenario: CY006 - Consult existing account in the database
    * def user_id = data_file.data_accounts.valid_account_1.userId
    * def token = data_file.data_accounts.valid_account_1.token
    * def username = data_file.data_accounts.valid_account_1.username
    Given path '/Account/v1/User', user_id
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + token
    When method get
    Then status 200
    And match response contains { userId: #(user_id), username: #(username)}

  @ConsultAllBooksSuccessfully
  Scenario: CY007 - Consult all books in the database
    Given path '/BookStore/v1/Books'
    When method get
    Then status 200
    And match response.books == '#[8]'

  @RelateBookToAccountSuccessfully
  Scenario: CY008 - Relate book to account successfully
    * def user_id = data_file.data_accounts.valid_account_1.userId
    * def body = read('classpath:services/bookstore/data/payload/book.json')
    Given path '/BookStore/v1/Books'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + data_file.data_accounts.valid_account_1.token
    And request body
    When method post
    Then status 201
    And match response.books == '#[3]'

  @ConsultBookByIsbnSuccessfully
  Scenario: CY009 - Consult book by isbn
    * params { ISBN: '9781449365035' }
    Given path '/BookStore/v1/Book'
    And header Content-Type = 'application/json'
    When method get
    Then status 200
    And match response.isbn == '9781449365035'

  @DeleteAccountBookByIsbnSuccessfully
  Scenario: CY010 - Delete account book by isbn successfully
    * def user_id = data_file.data_accounts.valid_account_1.userId
    * def isbn_id = '9781449365035'
    * def body = read('classpath:services/bookstore/data/payload/delete_account_book.json')
    Given path '/BookStore/v1/Book'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + data_file.data_accounts.valid_account_1.token
    And request body
    When method delete
    Then status 204

  @DeleteAllAccountBooksSuccessfully
  Scenario: CY011 - Delete all account books successfully
    * def user_id = data_file.data_accounts.valid_account_1.userId
    * def token = data_file.data_accounts.valid_account_1.token
    * params { UserId: '#(user_id)' }
    Given path '/BookStore/v1/Books'
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + token
    When method delete
    Then status 204

  @DeleteAccountSuccessfully
  Scenario: CY012 - Delete account successfully
    * def user_id = data_file.data_accounts.valid_account_1.userId
    * def token = data_file.data_accounts.valid_account_1.token
    Given path '/Account/v1/User', user_id
    And header Content-Type = 'application/json'
    And header Authorization = 'Bearer ' + token
    When method delete
    Then status 204
