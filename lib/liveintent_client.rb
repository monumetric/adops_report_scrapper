require 'date'
require_relative 'base_client'

class LiveintentClient < BaseClient
  REPORT_NAME = 'Report for ad_report_scrapper'

  private

  def login
    @client.visit 'https://lfm.liveintent.com/'
    @client.fill_in 'username', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Login'
    byebug
    begin
      @client.find :xpath, '//*[text()="Analysis"]'
    rescue Exception => e
      raise e, 'Liveintent login error'
    end
  end

  def scrap
    create_report_if_not_exist
    run_report
    extract_data_from_report
  end

  def create_report_if_not_exist
    @client.find(:xpath, '//*[text()="Analysis"]').click
    @client.find(:xpath, '//*[contains(text(),"Reporting")]').click
    sleep 1
    return if @client.find_all(:xpath, "//*[text()=\"#{REPORT_NAME}\"]").count > 0
    @client.find(:xpath, '//*[text()="New"]').click
  end

  def run_report
    @client.find(:xpath, '//option[text()="Yesterday"]').select_option
    sleep 5
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//td/table/*/tr'
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end

  # waitforspin
  # fa fa-spinner fa-spin
end