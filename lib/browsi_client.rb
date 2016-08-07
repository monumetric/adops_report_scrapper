require 'date'
require_relative 'base_client'
require 'open-uri'

class BrowsiClient < BaseClient
  private

  def login
    @client.visit 'https://reports.brow.si'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.find(:xpath, '//*[text()="Login"]').click
    begin
      @client.find :css, '.ico-calendar'
    rescue Exception => e
      raise e, 'Browsi login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    date_range_obj = {
      startDate: @date.to_time.utc.strftime('%FT%T.000Z'),
      endDate: (@date.to_time+86400-1).utc.strftime('%FT%T.999Z')
    }
    @client.visit "https://reports.brow.si/client/app/index.html#/report/home?dateRange=#{URI::encode(date_range_obj.to_json)}"
    sleep 5
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//li[@ng-class="{opened:site.isGraphOpen}"]'
    @data = [['Site', 'Revenues', 'Page Views']]
    @data += rows.map do |row|
      site = row.find_css('.header-full').first.visible_text
      rev = @client.find_all(:xpath, row.path+'//*[../span[text()="Revenues"]]').first.text
      pv = @client.find_all(:xpath, row.path+'//*[../span[text()="Page Views"]]').first.text
      [site, rev, pv]
    end
  end
end