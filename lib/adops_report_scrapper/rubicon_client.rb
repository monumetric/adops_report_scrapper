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
    tz = date.to_time.dst? ? '-07:00' : '-08:00'
    date_str = date.strftime '%F'
    date_start_str = "#{date_str}T00:00:00#{tz}"
    date_end_str = "#{date_str}T23:59:59#{tz}"
    byebug

    response = RestClient::Request.execute method: :get, url: 'https://api.rubiconproject.com/analytics/v1/report/', user: @login, password: @secret, account: "publisher/#{@account_id}", start: date_start_str, end: date_end_str, dimensions: ['date'], metrics: ['revenue']

    date_str = @date.strftime('%-m/%-d/%Y')
    time_zone_id = 'Eastern Standard Time'

    response = RestClient.post "https://ui.adsupply.com/PublicPortal/Publisher/#{@login}/Report/Export", SqlCommandId: '', ExportToExcel: 'False', IsOLAP: 'False', DateFilter: date_str, TimeZoneId: time_zone_id, Grouping: '1', 'DimPublisher.Value': "#{@login}~", 'DimPublisher.IsActive': 'True', 'DimSiteName.Value': '', 'DimSiteName.IsActive': 'True', 'DimCountry.Value': '', 'DimCountry.IsActive': 'True', 'DimMediaType.Value': '', 'DimMediaType.IsActive': 'True', ApiKey: @secret

    data = JSON.parse response
    header = data[0].keys
    @data = [header]
    @data += data.map do |datum|
      header.map { |key| datum[key] }
    end
  end
end