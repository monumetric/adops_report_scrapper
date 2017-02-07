require 'date'
require_relative 'base_client'

class AdopsReportScrapper::ImonomyClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 7
    false
  end

  private

  def login
    @client.visit 'http://dashboard.imonomy.com/'
    @client.fill_in 'Username', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Sign In'
    begin
      @client.find :xpath, '//*[text()="My Statistics"]'
    rescue Exception => e
      raise e, 'Imonomy login error'
    end
  end

  def scrap
    @data = []
    return if @date == Date.today - 1 # imonomy never update revenues for in 1 day
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[text()="My Statistics"]').click

    @client.find(:xpath, '//option[text()="Last 7 Days"]').select_option
    @client.check 'Website'
    @client.check 'Country'
    @client.check 'Device'

    @client.click_link 'Submit'
    sleep 10

    @client.find(:xpath, '//option[text()="100"]').select_option
  end

  def extract_data_from_report
    until @client.find(:xpath, '//*[text()=">"]')[:disabled] == "disabled"
      rows = @client.find_all :xpath, %Q{//table/tbody/tr[./td[text()="#{@date.strftime('%d.%m.%Y')}"]]}
      rows = rows.to_a
      if @data.count == 0
        header = @client.find :xpath, '//table/thead/tr'
        n_header = header.find_css('td,th').map { |td| td.visible_text }
        @data << n_header
      end
      @data.concat rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }

      @client.find(:xpath, '//*[text()=">"]').click
      sleep 1
    end
  end
end