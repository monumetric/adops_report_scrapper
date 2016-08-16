require 'date'
require_relative 'base_client'

class AdopsReportScrapper::SonobiClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://jetstream.sonobi.com/welcome/login.php'
    @client.fill_in 'user name', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Submit'
    begin
      @client.find :xpath, '//*[text()="dashboard"]'
    rescue Exception => e
      raise e, 'Sonobi login error'
    end
  end

  def scrap
    @data = []
    request_report(:us)
    extract_data_from_report(:us)
    request_report(:intl)
    extract_data_from_report(:intl)
  end

  def request_report(country)
    is_us = country == :us
    @client.find(:xpath, '//*[text()="Reports"]').click
    sleep 2
    # all sites
    @client.find(:xpath, '//div[@name="_siteid"]').click
    sleep 2
    @client.find(:xpath, '//*[text()="Select All"]').click

    # select country
    @client.find(:xpath, '//*[text()="Add New Filter"]').click
    @client.find_all(:xpath, '//option[text()="Country"]').last.select_option
    sleep 2
    @client.find(:xpath, '//div[@name="_country"]').click
    sleep 2
    if is_us
      @client.find(:xpath, '//*[text()="United States"]').click
    else
      @client.find(:xpath, '//*[text()="Select All"]').click
      @client.find(:xpath, '//*[@class="remove_icon"][../*[text()="United States"]]').click
    end

    # check group by
    @client.check 'Date'
    @client.check 'Placement'
    @client.check 'Site'
    @client.check 'Clicks'
    @client.check 'Views'
    @client.check 'Unfilled Impressions'
    @client.check 'Device Type'

    @client.click_button 'Run Report'
    sleep 1
    wait_for_spin
  end

  def extract_data_from_report(country)
    rows = @client.find_all :xpath, '//*[@class="reports_tab_item_body"]//table/*/tr'
    rows = rows.to_a
    header = rows.shift
    if @data.count == 0
      n_header = header.find_css('td,th').map { |td| td.visible_text }
      n_header << 'Country'
      @data << n_header
    end
    rows.shift
    @data += rows.map do |row|
      n_row = row.find_css('td,th').map { |td| td.visible_text }
      n_row << country.to_s.upcase
      n_row
    end
  end

  def wait_for_spin
    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '.circle xlarge')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 5
  end
end
