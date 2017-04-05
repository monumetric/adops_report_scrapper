require 'date'
require_relative 'base_client'
require 'httpclient'

class AdopsReportScrapper::SpotxchangeClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date < Date.today
    false
  end

  private

  def init_client
    fail 'please specify spotxchange oauth client_id' unless @options['client_id']
    @client_id = @options['client_id']
    fail 'please specify spotxchange oauth client_secret' unless @options['client_secret']
    @client_secret = @options['client_secret']
    super
  end

  def before_quit_with_error
  end

  def scrap
    date_str = @date.strftime('%Y-%m-%d')

    @client.visit "https://publisher-api.spotxchange.com/oauth2/publisher/approval.html?client_id=#{@client_id}&response_type=code&state=xyz"
    @client.click_button 'Accept'

    @client.fill_in 'Username', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Login'

    @client.click_button 'Accept'
    sleep 1

    code = URI::decode_www_form(URI.parse(@client.driver.network_traffic.last.url).query).to_h['code']

    body = { 'client_id' => @client_id, 'client_secret' => @client_secret, 'grant_type' => 'authorization_code', 'code' => code }
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