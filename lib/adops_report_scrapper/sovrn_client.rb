require 'date'
require_relative 'base_client'

class AdopsReportScrapper::SovrnClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 7
    false
  end

  private

  def login
    @client.visit 'https://meridian.sovrn.com/#welcome'
    sleep 5
    if @client.find_all(:css, '#user-menu-trigger').count > 0
      @client.find_all(:css, '#user-menu-trigger').first.click
      sleep 1
      @client.find(:xpath, '//li[@data-value="logout"]').click
    end
    @client.fill_in 'login_username', :with => @login
    @client.fill_in 'login_password', :with => @secret
    @client.click_link 'Log In'

    begin
      @client.find :xpath, '//*[text()="Account"]'
    rescue Exception => e
      raise e, 'sovrn login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.visit 'https://meridian.sovrn.com/#account/my_downloads'
    @client.save_screenshot
    sleep 5
    if @client.find_all(:xpath, '//input[@value="domestic_and_international"]').count == 0
      login
      @client.visit 'https://meridian.sovrn.com/#account/my_downloads'
      sleep 5
    end
    @client.find(:xpath, '//input[@value="domestic_and_international"]').set(true)

    @client.fill_in 'adstats-date-range-start-month', :with => @date.strftime('%m')
    @client.fill_in 'adstats-date-range-start-day', :with => @date.strftime('%d')
    @client.fill_in 'adstats-date-range-start-year', :with => @date.strftime('%Y')

    @client.fill_in 'adstats-date-range-end-month', :with => @date.strftime('%m')
    @client.fill_in 'adstats-date-range-end-day', :with => @date.strftime('%d')
    @client.fill_in 'adstats-date-range-end-year', :with => @date.strftime('%Y')

    @client.find_all(:xpath, '//button[text()=" Download "]').first.click

    sleep 2

    url = @client.driver.network_traffic[-1].url
    headers = @client.driver.network_traffic[-1].headers

    @response = HTTPClient.get url, header: headers.map{ |header| [header['name'], header['value']] }.to_h
  end

  def extract_data_from_report
    rows = CSV.parse @response.body
    @data = rows[6..-1]
  end
end
