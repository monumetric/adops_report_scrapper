require 'date'
require_relative 'base_client'

class AdopsReportScrapper::AdforgeClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'http://495.as.adforgeinc.com/www/admin/index.php'
    @client.fill_in 'username', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Login'
    begin
      @client.find :xpath, '//*[text()="Reports"]'
    rescue Exception => e
      raise e, 'Adforge login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.within_frame @client.find(:tag, :iframe) do
      @client.find(:xpath, '//option[text()="Yesterday"]').select_option
      @client.click_button 'Submit'
    end
    sleep 5
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//td/table/*/tr'
    rows = rows.to_a
    rows.delete_at 1
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end
end