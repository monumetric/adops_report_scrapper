require 'date'
require_relative 'base_client'
require 'google/api_client'
require 'google/api_client/service'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'csv'

# require option with network_id to be passed into constructor
class AdopsReportScrapper::AdsenseClient < AdopsReportScrapper::BaseClient
  API_NAME = 'adsense'
  API_VERSION = 'v1.4'
  CREDENTIAL_STORE_FILE = "#{API_NAME}-oauth2.json"
  API_SCOPE = 'https://www.googleapis.com/auth/adsense.readonly'

  private

  def init_client
    fail 'please specify adsense account id' unless @options['account_id']
    @account_id = @options['account_id']
    authorization = nil

    file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
    if file_storage.authorization.nil?
      flow = Google::APIClient::InstalledAppFlow.new(
        :client_id => @login,
        :client_secret => @secret,
        :scope => [API_SCOPE]
      )
      authorization = flow.authorize(file_storage)
    else
      authorization = file_storage.authorization
    end

    @client = Google::APIClient::Service.new(API_NAME, API_VERSION,
      {
        :application_name => "Ruby #{API_NAME} ad report scrapper",
        :application_version => '1.0.0',
        :authorization => authorization
      }
    )
  end

  def scrap
    result = @client.accounts.reports.generate(
        :accountId => @account_id,
        :startDate => 'today-1d',
        :endDate => 'today-1d',
        :metric => ['AD_REQUESTS', 'INDIVIDUAL_AD_IMPRESSIONS', 'CLICKS', 'EARNINGS'],
        :dimension => ['DATE', 'AD_UNIT_CODE', 'AD_UNIT_NAME', 'COUNTRY_CODE', 'PLATFORM_TYPE_NAME'],
        :alt => 'csv').execute
    @data = CSV.parse(result.body)
  end
end