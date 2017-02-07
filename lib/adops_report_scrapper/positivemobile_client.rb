require 'date'
require_relative 'base_client'

class AdopsReportScrapper::PositivemobileClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 7
    false
  end

  private

  def login
    @client.visit 'https://rapidv.positivemobile.com/'
    @client.fill_in 'Username', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Sign in'
    begin
      @client.find :xpath, '//*[text()="Reports"]'
    rescue Exception => e
      raise e, 'Positivemobile login error'
    end


    cookies = @client.driver.cookies
    @client = HTTPClient.new
    @client.cookie_manager.cookies = cookies.values.map do |cookie|
      cookie = cookie.instance_variable_get(:@attributes)
      HTTP::Cookie.new cookie
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    date_str = @date.strftime('%Y-%m-%d')

    header = {
      Accept: 'Accept:application/json, text/plain, */*',
      Origin: 'https://rapidv.positivemobile.com',
      Referer: ':https//rapidv.positivemobile.com/reports',
      'User-Agent': 'Mozilla/5.0 (Unknown; Linux x86_64) AppleWebKit/538.1 (KHTML, like Gecko) PhantomJS/2.1.1 Safari/538.1',
      'Content-Type': 'application/json',
    }

    body = {
      dimensions: ['tagName', 'udc'],
      filters: [],
      from: "#{date_str}T00:00:00.000Z",
      metrics: ['imp', 'revenue_publisher_cpm', 'dspimpv'],
      timeFrame: 'Custom',
      timeLevel: 'Daily',
      timeZone: 'America/New_York',
      to: "#{date_str}T00:00:00.000Z",
      type: 'Supply'
    }.to_json

    @response = @client.post('https://rapidv.positivemobile.com/api/reports/run', header: header, body: body )
  end

  def extract_data_from_report
    rows = JSON.parse @response.body
    keys = rows.first.keys
    @data = [keys]
    @data += rows.map(&:values)
  end
end
