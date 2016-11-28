require 'date'
require_relative 'base_client'
require 'google/api_client'
require 'google/api_client/service'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'csv'

# require option with network_id to be passed into constructor
class AdopsReportScrapper::AdxClient < AdopsReportScrapper::BaseClient
  API_NAME = 'adexchangeseller'
  API_VERSION = 'v2.0'
  CREDENTIAL_STORE_FILE = "#{API_NAME}-oauth2.json"
  API_SCOPE = 'https://www.googleapis.com/auth/adexchange.seller.readonly'

  def date_supported?(date = nil)
    _date = date || @date
    return true if _date < Date.today
    false
  end

  private

  def init_client
    fail 'please specify adx account id' unless @options['account_id']
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
    date_str = @date.strftime('%Y-%m-%d')
    option = {
        :accountId => @account_id,
        :startDate => date_str,
        :endDate => date_str,
        :metric => ['AD_REQUESTS', 'AD_IMPRESSIONS', 'CLICKS', 'EARNINGS'],
        :dimension => ['DATE', 'DFP_AD_UNITS', 'DFP_AD_UNIT_ID', 'COUNTRY_CODE', 'PLATFORM_TYPE_NAME', 'PRODUCT_NAME'],
        :alt => 'csv'
    }
    result = @client.accounts.reports.generate(option).execute
    @data = CSV.parse(result.body)
  end
end