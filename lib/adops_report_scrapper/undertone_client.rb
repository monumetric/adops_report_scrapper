require 'date'
require_relative 'base_client'

class AdopsReportScrapper::UndertoneClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 3
    false
  end

  private

  def login
    @client.visit 'https://insights.undertone.com/user/login'
    @client.fill_in 'user_email', :with => @login
    @client.fill_in 'user_password', :with => @secret
    @client.click_button 'Sign In'
    begin
      @client.find :xpath, '//*[text()="Reporting"]'
    rescue Exception => e
      raise e, 'Undertone login error'
    end
  end

  def scrap
    request_zone_report
    extract_data_from_zone_report
    request_po_report
    extract_data_from_po_report
  end

  def request_zone_report
    date_str = date.strftime('%m/%d/%Y')
    @client.fill_in 'start', :with => date_str
    @client.fill_in 'end', :with => date_str
    sleep 2
    @client.select 'Zone Report - Publishers', :from => 'report_id'
    sleep 2
    @client.click_button 'html'
    sleep 10
  end

  def extract_data_from_zone_report
    @client.within_window @client.driver.browser.window_handles.last do
      @data = []
      rows = @client.find_all :xpath, '//table/*/tr[not(contains(@class, "text"))]'
      rows = rows.to_a
      rows.pop
      @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
    end
  end

  def request_po_report
    date_str = date.strftime('%m/%d/%Y')
    @client.fill_in 'start', :with => date_str
    @client.fill_in 'end', :with => date_str
    sleep 2
    @client.select 'Purchase Order Summary', :from => 'report_id'
    sleep 2
    @client.click_button 'html'
    sleep 10
  end

  def extract_data_from_po_report
    @client.within_window @client.driver.browser.window_handles.last do
      rows = @client.find_all :xpath, '//table/*/tr[not(contains(@class, "text"))]'
      rows = rows.to_a
      rows.pop
      rows.pop
      keys = rows.shift
      keys = keys.find_css('td,th').map { |td| td.visible_text }
      valuess = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
      l_data = valuess.map { |values| Hash[keys.zip(values)] }
      @data[0] << 'Revenue'
      l_data.each do |l_datum|
        @data.each_with_index do |datum, i|
          next if i == 0
          next unless datum[0].downcase.tr(' ','').include? "-#{l_datum['Ad Unit'].downcase.tr(' ','')}-"
          @data[i] << datum[3].tr(',','').to_i * l_datum['Sales Price'].tr('USD','').to_f / 1000
        end
      end
    end
  end
end
