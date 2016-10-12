require 'date'
require_relative 'base_client'

class AdopsReportScrapper::RhythmoneClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://portal.rhythmone.com/login'
    sleep 1
    return if @client.find_all(:xpath, '//*[contains(text(),"REPORTING")]').count > 0
    @client.fill_in 'email', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Sign in'

    begin
      @client.find :xpath, '//*[contains(text(),"REPORTING")]'
    rescue Exception => e
      raise e, 'Rhythmone login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[contains(text(),"REPORTING")]').click
    wait_for_loading
    @client.find(:xpath, '//option[contains(text(),"Yesterday")]').select_option
    sleep 1
    @client.find(:xpath, '//select[@ng-model="filter.group1"]').find(:xpath, 'option[contains(text(),"Placement")]').select_option
    wait_for_loading
    @client.click_button 'Generate report'
    sleep 2
    wait_for_loading
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//table/*/tr'
    rows = rows.to_a
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end

  def wait_for_loading
    30.times do |_i| # wait 5 min
      begin
        @client.find(:xpath, '//overlay-spinner/div')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 10
  end
end