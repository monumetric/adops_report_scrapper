require 'date'
require_relative 'base_client'
require 'httpclient'

class AdopsReportScrapper::SpotxchangeClient < AdopsReportScrapper::BaseClient
  private

  def init_client
    fail 'please specify spotxchange oauth code' unless @options['code']
    @code = @options['code']
  end

  def before_quit_with_error
  end

  def scrap
    date_str = @date.strftime('%Y-%m-%d')

    body = { 'client_id' => @login, 'client_secret' => @secret, 'grant_type' => 'authorization_code', 'code' => @code }
    response = HTTPClient.post 'https://publisher-api.spotxchange.com/1.0/token', body
    token = JSON.parse(response.body)['value']['data']['access_token']

    header = { 'Authorization' => "Bearer #{token}" }
    response = HTTPClient.get 'https://api.spotxchange.com/1.0/me', nil, header
    publisher_id = JSON.parse(response.body)['value']['affiliate_id']

    response = HTTPClient.get "https://api.spotxchange.com/1.0/Publisher(#{publisher_id})/Channels/TrafficReport", { date_range: "#{date_str}|#{date_str}" }, header
    data = JSON.parse(response.body)['value']['data']

    @data = []

    header = data[0].keys
    @data = [header]
    @data += data.map { |datum| header.map { |key| datum[key].is_a?(Hash) ? datum[key]['value'] : datum[key] } }
  end
end