require 'date'
require_relative 'base_client'
require 'rest-client'

class AdopsReportScrapper::AdsupplyClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date < Date.today
    false
  end

  def init_client
  end

  def before_quit_with_error
  end

  private

  def scrap
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