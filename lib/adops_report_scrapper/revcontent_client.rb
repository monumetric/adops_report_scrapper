require 'date'
require_relative 'base_client'

class AdopsReportScrapper::RevcontentClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://www.revcontent.com/login'
    @client.fill_in 'name', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Sign In'
    begin
      @client.find :xpath, '//*[contains(text(),"Widgets")]'
    rescue Exception => e
      raise e, 'Revcontent login error'
    end
  end

  def scrap
    @client.find(:xpath, '//*[contains(text(),"Widgets")]').click
    @client.find(:css, '.fa.fa-calendar').click
    @client.find(:xpath, '//*[text()="Yesterday"]').click
    @data = []
    %w(desktoplg desktop tablet phone unknown).each do |device|
      request_report(device)
      extract_data_from_report(device)
    end
  end

  def request_report(device)
    @client.find(:css, '.fa.fa-desktop').click
    @client.find(:xpath, '//*[text()="All Devices"]').click
    @client.find(:css, '.fa.fa-desktop').click
    @client.check device
  end

  def extract_data_from_report(device)
    rows = @client.find_all :xpath, '//table/*/tr'
    rows = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
    header = rows.shift
    rows.shift
    if @data.count == 0
      header.unshift 'Device'
      @data << header
    end
    rows.each do |row|
      row.unshift device
    end
    @data += rows
  end
end