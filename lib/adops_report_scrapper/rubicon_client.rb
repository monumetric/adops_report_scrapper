require 'date'
require_relative 'base_client'
require 'rest-client'

class AdopsReportScrapper::RubiconClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date < Date.today
    false
  end

  def init_client
    fail 'please specify rubicon account id' unless @options['account_id']
    @account_id = @options['account_id']
  end

  def before_quit_with_error
  end

  private

  def scrap
    date_str = date.strftime '%F'

    header_params = { Accept: 'application/json', params: { start: date_str, end: date_str, columns: 'Time_Date,Site_NameShort,Country_Name,Prorated_NetworkImpressions,Prorated_Revenue', source: 'standard' } }
    response = RestClient::Request.execute method: :get, url: "https://api.rubiconproject.com/sellers/api/reports/v1/#{@account_id}/", user: @login, password: @secret, headers: header_params

    data = JSON.parse response.body
    @data = [data['columns']]
    @data += data['results'].map(&:values)
  end
end
