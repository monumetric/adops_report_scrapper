require 'date'
require_relative 'base_client'

class AdopsReportScrapper::TripleliftClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://console.triplelift.com/login'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Sign in'
    begin
      @client.find :xpath, '//*[text()="Reporting"]'
    rescue Exception => e
      raise e, 'Triplelift login error'
    end
  end

  def scrap
    @date_str = @date.strftime('%B %d, %Y')
    @client.find(:xpath, '//*[text()="Reporting"]').click
    wait_for_spin
    @client.find(:xpath, '//button[contains(text(),"Month to date")]').click
    @client.find(:xpath, '//a[contains(text(),"Yesterday")]').click
    sleep 1
    
    @client.find(:xpath, '//tl-checkbox/div/span[text()[normalize-space()="Placement"]]').click
    sleep 1
    @client.find(:xpath, '//tl-checkbox/div/span[text()[normalize-space()="Clicks"]]').click
    sleep 1
    @client.find(:xpath, '//*[text()[normalize-space()="Run query"]]').click
    sleep 10

    extract_data
  end

  def extract_data
    @data = []
    return if @client.find_all(:xpath, '//*[text()="No data available for selected date range"]').count > 0

    rows = @client.find_all :xpath, '//table/*/tr'
    rows = rows.to_a
    rows.pop
    header = rows.shift
    n_data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
    if @data.count == 0
      n_header = header.find_css('td,th').map { |td| td.visible_text }
      @data << n_header
    end
    @data += n_data
  end

  def wait_for_spin
    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '.spinner')
      rescue Exception => e
        break
      end
      sleep 5
    end
    sleep 2
  end
end