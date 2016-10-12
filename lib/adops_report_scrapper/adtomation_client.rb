require 'date'
require_relative 'base_client'

class AdopsReportScrapper::AdtomationClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'http://console.adtomation.com/'
    @client.fill_in 'Username', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Sign In'

    begin
      @client.find :xpath, '//*[text()="Reporting"]'
    rescue Exception => e
      raise e, 'Adtomation login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.click_link 'Your Reports'
    @client.find(:xpath, '//*[../../../../../td[text()="report created by adops report scrapper"] and contains(text(),"Run")]').click
    sleep 5
    wait_for_loading
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//table/*/tr'
    rows = rows.to_a
    rows.pop
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end

  def wait_for_loading
    30.times do |_i| # wait 5 min
      begin
        @client.find(:xpath, '//*[text()="Loading..."]')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 2
  end
end