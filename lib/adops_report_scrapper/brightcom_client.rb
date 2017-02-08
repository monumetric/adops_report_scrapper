require 'date'
require_relative 'base_client'

class AdopsReportScrapper::BrightcomClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://compass.brightcom.com/'
    @client.fill_in 'Username', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Login'
    sleep 15
    begin
      @client.find :xpath, '//*[text()="Reports "]'
    rescue Exception => e
      raise e, 'Brightcom login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.visit 'https://compass.brightcom.com/onetag/reportsext/display'
    sleep 5

    group_by_dest_elem = @client.find(:css, '#group_by_dest')
    @client.find(:xpath, '//div[text()="Tags" and @data-order="1"]').drag_to(group_by_dest_elem)
    @client.find(:xpath, '//div[text()="Country" and @data-order="2"]').drag_to(group_by_dest_elem)

    metrics_source_elem = @client.find(:css, '#metrics_source')
    metrics_dest_elem = @client.find(:css, '#metrics_dest')
    @client.find(:xpath, '//div[text()="Received IMPS" and @data-order="0"]').drag_to(metrics_dest_elem)
    @client.find(:xpath, '//div[text()="Clicks" and @data-order="3"]').drag_to(metrics_dest_elem)
    @client.find(:xpath, '//div[text()="Conversion Rate" and @data-order="6"]').drag_to(metrics_source_elem)
    @client.find(:xpath, '//div[text()="Revenue eCPM" and @data-order="8"]').drag_to(metrics_source_elem)

    @client.click_button 'Run Report'
    sleep 15
  end

  def extract_data_from_report
    rows = @client.find_all(:xpath, '//table[@role="grid"]/tbody/tr')
    rows = rows.to_a
    header = @client.find :xpath, '//table[@role="grid"]/thead/tr'
    n_header = header.find_css('td,th').map { |td| td.visible_text }
    @data = [n_header]
    @data += rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end
end
