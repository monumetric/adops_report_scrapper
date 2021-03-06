require 'date'
require_relative 'base_client'

# gcs sometimes doesn't update data in 24 hours

class AdopsReportScrapper::GcsClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 7
    false
  end

  private

  def login
    @client.visit 'https://www.google.com/insights/consumersurveys/your-surveys'
    @client.fill_in 'Email', :with => @login
    @client.click_button 'Next'
    @client.fill_in 'Passwd', :with => @secret
    @client.click_button 'Sign in'
    # for veirfication
    # cc = @client.find :xpath, '//*[contains(text(),"the recovery phone")]'
    # cc.click
    # @client.fill_in 'Enter phone number', :with => @options[:recovery_phone]
    # @client.click_button 'Done'
    begin
      @client.find :xpath, '//*[text()="Sites"]'
    rescue Exception => e
      raise e, 'Gcs login error'
    end
  end

  def scrap
    sites = @client.find_all(:xpath, '//*[contains(@class,"sites-menu-item")]', visible: false)
    sites = sites.to_a
    sites.pop
    n_sites = sites.map do |site|
      {
        name: site.text(:all),
        url: site[:href].sub('settings', 'report')
      }
    end.reject { |site| site[:url].include? 'websat' }
    @data = []
    n_sites.each do |site|
      request_report site
      extract_data_from_report site
    end
  end

  def request_report(site)
    @client.visit site[:url]
  end

  def extract_data_from_report(site)
    rows = @client.find_all :xpath, %Q{//table/*/tr[./td[contains(text(),"#{@date.strftime('%b')}") and contains(text(),"#{@date.strftime('%e, %Y')}")]]}
    return if rows.count == 0
    if @data.count == 0
      header = @client.find :xpath, '//table/thead/tr'
      n_header = header.find_css('td,th').map { |td| td.visible_text }
      n_header.unshift 'Site'
      @data << n_header
    end
    row = rows[0].find_css('td,th').map { |td| td.visible_text }
    row.unshift site[:name]
    @data << row
  end
end