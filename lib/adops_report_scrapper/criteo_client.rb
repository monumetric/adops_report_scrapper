require 'date'
require_relative 'base_client'
require 'httpclient'

class AdopsReportScrapper::CriteoClient < AdopsReportScrapper::BaseClient
  private

  def init_client
  end

  def before_quit_with_error
  end

  def scrap
    @data = []
    date_str = @date.strftime('%Y-%m-%d')

    response = HTTPClient.get "https://publishers.criteo.com/api/2.0/stats.json", apitoken: @secret, begindate: date_str, enddate: date_str

    data = JSON.parse response.body
    header = data[0].keys
    @data = [header]
    @data += data.select { |datum| datum['date'].split('T')[0] == date_str }.map { |datum| header.map { |key| datum[key].is_a?(Hash) ? datum[key]['value'] : datum[key] } }
  end
end