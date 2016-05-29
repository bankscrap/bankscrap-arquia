require 'bankscrap'
require 'securerandom'

module Bankscrap
  module Arquia
    class Bank < ::Bankscrap::Bank

      # Define the endpoints for the Bank API here
      BASE_ENDPOINT     = 'https://api.arquia.es'.freeze
      AUTH_ENDPOINT     = '/api/Auth'.freeze
      TOKEN_ENDPOINT    = '/token'.freeze
      USER_ENDPOINT     = '/api/user'.freeze
      PRODUCTS_ENDPOINT = '/api/products'.freeze
      ACCOUNTS_ENDPOINT = '/api/accounts'.freeze

      REQUIRED_CREDENTIALS  = [:user, :password, :nif]

      def initialize(credentials = {})
        super do
          @nif = @nif.dup.upcase

          add_headers(
            'Authorization' => 'Bearer',
            'api-version' => '2',
            'Content-Type' => 'application/json; charset=utf-8',
            'Host' =>  'api.arquia.es',
            'User-Agent' => ''
          )
        end
      end

      # Fetch all the accounts for the given user
      #
      # Should returns an array of Bankscrap::Account objects
      def fetch_accounts
        # First we need to fetch the products / views for the user
        
        user_response = JSON.parse(get(BASE_ENDPOINT + USER_ENDPOINT))
        view = user_response['views'].find { |view| view['type'] == 0}
        view_id = view['id']

        # Now we get the accounts for that product / view
        products_response = JSON.parse(get(BASE_ENDPOINT + PRODUCTS_ENDPOINT + "/#{view_id}"))

        # Find which products are accounts
        products_response.select! do |product|
          product['$type'] == 'Arquia.Backend.Domain.Models.Entities.Account, Arquia.Backend.Domain.Models'
        end

        products_response.map { |account| build_account(account) }
      end

      # Fetch transactions for the given account.
      #
      # Account should be a Bankscrap::Account object
      # Should returns an array of Bankscrap::Account objects
      def fetch_transactions_for(account, start_date: Date.today - 1.month, end_date: Date.today)
        from = format_date(start_date)
        to = format_date(end_date)
        page = 1
        transactions = []

        loop do
          url = BASE_ENDPOINT + ACCOUNTS_ENDPOINT + "/#{account.id}/extract/from/#{from}/to/#{to}/page/#{page}"
          response = get(url)
          json = JSON.parse(response)
          transactions += json.map do |data|
            build_transaction(data, account)
          end
          page += 1
          break unless json.any?
        end

        transactions
      end

      private

      def login
        # First step for login: request keyboard positions
        params = {
          "$type" => "Arquia.Backend.Domain.Models.ValueObjects.IdentificationData, Arquia.Backend.Domain.Models",
          "DocumentId" => @nif,
          "UserName" => @user
        }
        auth_response = JSON.parse(post(BASE_ENDPOINT + AUTH_ENDPOINT, fields: params.to_json))
        keyboard_order = auth_response['order']
        required_pw_positions = auth_response['positions']
        identifier = auth_response['identifier']

        # Second step: get token
        params = {
          'client_id' => 'mobilefrontend',
          'grant_type' => 'password',
          'documentid' => @nif,
          'username' =>  @user,
          'positions' => get_correct_positions(keyboard_order, required_pw_positions),
          'ChallengeId' => identifier,
          'client_version' => '1.1.5'
        }

        # Note this request is a form type, not a json, that's why we don't use params.to_json
        token_response = JSON.parse(post(BASE_ENDPOINT + TOKEN_ENDPOINT, fields: params))        
        token = token_response['access_token']

        # Set the token as header for future requests
        add_headers(
          'Authorization' => "Bearer #{token}"
        )
      end

      # Build an Account object from API data
      def build_account(data)
        Account.new(
          bank: self,
          id: data['numProd'],
          name: data['description'],
          available_balance: data['availableBalance'],
          balance: data['balance'],
          currency: 'EUR',
          iban: data['iban']['ibanCode'],
          description: data['description']
        )
      end

      # Build a transaction object from API data
      def build_transaction(data, account)
        Transaction.new(
          account: account,
          id: data['id'],
          amount: Money.new(data['amount'].to_f * 100, 'EUR'),
          description: data['description'],
          effective_date: data['valueDate'].to_date, # Format is 2016-05-02T00:00:00
          currency: 'EUR', # We only know the API returns data['currency'] == 0 for EUR
          balance: Money.new(data['balance'].to_f * 100, 'EUR')
        )
      end

      private

      # Example:
      # @password = '12345678'
      # get_correct_positions("4912650378", "03") => "20"
      # Required position 0 is "1", which matches position 2
      # Required position 3 is "4", which matches position 0
      def get_correct_positions(keyboard_order, required_pw_positions)
        required_pw_positions.chars.collect do |position|
          keyboard_order.index(@password[position.to_i])
        end.join
      end

      def format_date(date)
        date.strftime('%Y-%m-%d')
      end
    end
  end
end
