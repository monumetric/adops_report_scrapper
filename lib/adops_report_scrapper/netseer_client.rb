require 'date'
require_relative 'base_client'

class AdopsReportScrapper::NetseerClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'http://publisher.netseer.com/login'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Login'
    begin
      @client.find :css, '.icon-calender'
    rescue Exception => e
      raise e, 'Netseer login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    sleep 3
    @client.find(:xpath, '//*[contains(text(),"Run Reports")]').click
    wait_for_loading

    @client.find(:css, '.icon-calender').click
    @client.fill_in 'daterangepicker_start', :with => @date.strftime('%m/%d/%Y')
    @client.fill_in 'daterangepicker_end', :with => @date.strftime('%m/%d/%Y')
    @client.click_button 'Apply'
    sleep 3

    @client.choose 'Day'
    @client.choose 'Tag'
    @client.check 'Delivery Medium'

    @client.click_link_or_button 'Run Report'
    wait_for_loading

  end

  def extract_data_from_report
    @data = []
    loop do
      rows = @client.find_all :xpath, '//table/*/tr'
      rows = rows.to_a
      header = rows.shift
      if @data.count == 0
        n_header = header.find_css('td,th').map { |td| td.visible_text }
        @data << n_header
      end
      @data += rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
      pagee = @client.find(:xpath, '//*[contains(text(),"Showing ")]').text.match(/to (\d+) of (\d+)/).captures
      break if pagee[0] == pagee[1]
      @client.find(:css, 'a > .fa.fa-angle-right').click
      wait_for_loading
    end
  end

  def wait_for_loading
    30.times do |_i| # wait 5 min
      begin
        @client.find(:xpath, '//*[text()="Loading ..."]')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 5
  end
end