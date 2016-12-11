require 'date'
require_relative 'base_client'

class AdopsReportScrapper::LittlethingsClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 4
    false
  end

  private

  def login
    @client.visit 'http://www.reportingthings.com'
    @client.fill_in 'email', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Sign In'
    begin
      @client.find :xpath, '//*[contains(text(),"Report")]'
    rescue Exception => e
      raise e, 'Littlethings login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[contains(text(),"Report")]').click
    pub_id = @client.body.match(/\/report\/story\/(\d+)\/all\/all/).captures[0]
    daterange_end_str = Date.today.strftime('%m/%d/%Y')
    daterange_begin_str = (Date.today - 5).strftime('%m/%d/%Y')
    daterange_str = "#{daterange_begin_str} - #{daterange_end_str}"
    @client.visit "http://www.reportingthings.com/report/story/#{pub_id}/all/all?type=revenue&daterange=#{URI.encode(daterange_str)}"
    utm_rows = @client.find_all(:xpath, '//*[contains(text(),"UTMs")]')
    utm_rows.each { |utm_row| utm_row.click }
  end

  def extract_data_from_report
    date_str = @date.strftime('%m/%d/%Y')
    rows = @client.find_all :xpath, '//table[@id="report-table"]/*/tr'
    rows = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
    header = rows.shift
    @data = [header]
    flag_found_date = false
    rows.each do |row|
      next unless row[0] == date_str || flag_found_date
      case row[0]
      when date_str
        flag_found_date = true
        unless row[1].include? 'UTMs'
          @data << row
          break
        end
        next
      when ''
        @data << row
        @data[-1][0] = date_str
        next
      else
        break
      end
    end
  end
end
