require 'date'
require_relative 'base_client'

class AdopsReportScrapper::AdaptvClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://onevideo.aol.com/#/logon'
    @client.fill_in 'adaptv_email', :with => @login
    @client.fill_in 'adaptv_password', :with => @secret
    @client.click_button 'Sign in >'
    begin
      @client.find :xpath, '//*[text()="Analytics"]'
    rescue Exception => e
      raise e, 'Adaptv login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[text()="Analytics"]').click
    @client.find(:xpath, '//*[text()="Reports"]').click
    wait_for_spin
    @client.find(:xpath, '//*[text()="New Report"]').click
    wait_for_spin

    @client.fill_in 'Report Name', :with => "tmp-#{Time.now.to_i}"

    @client.check 'Media'
    @client.check 'Geo: Country'

    @client.click_link 'Metrics'

    @client.check 'Ad Attempts'
    @client.check 'Ad Opportunities'
    @client.check 'Ad Break Impressions'
    @client.check 'Ad Impressions'
    @client.check 'IAB Viewable Ad Impressions'
    @client.check '100% Completed Views'
    @client.check 'Ad Skips'
    @client.check 'Clicks'
    @client.check 'Ad Revenue'

    @client.click_button 'Run Report'
    wait_for_spin

    @client.find(:xpath, '//option[text()="100"]').select_option
    sleep 5
  end

  def extract_data_from_report
    @data = []
    thead = @client.find :xpath, '//table[1]/thead/tr'
    @data << thead.find_css('td,th').map { |td| td.visible_text }
    99.times do |_i|
      rows = @client.find_all :xpath, '//table[1]/tbody/tr'
      @data += rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
      pagee = @client.find(:xpath, '//*[contains(text()," / ")]').text.split(' / ')
      break if pagee[0] == pagee[1]
      @client.click_button 'Next'
      sleep 5
    end
  end

  def wait_for_spin
    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '.busy-spinner-large')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 5
  end
end