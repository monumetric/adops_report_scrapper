require 'date'
require_relative 'base_client'

class AdopsReportScrapper::FacebookaudienceClient < AdopsReportScrapper::BaseClient
  private

  def init_client
    fail 'please specify facebook app id' unless @options['app_id']
    @app_id = @options['app_id']
    super
  end

  def login
    @client.visit "https://developers.facebook.com/apps/#{@app_id}/audience-network/placement"
    @client.fill_in 'email', :with => @login
    @client.fill_in 'pass', :with => @secret
    @client.click_button 'Log In'
    begin
      @client.find :xpath, '//*[text()="Dashboard"]'
    rescue Exception => e
      raise e, 'Facebookaudience login error'
    end
  end

  def scrap
    @client.find(:xpath, '//*[text()="All Ad Placements"]').click
    placements = @client.find_all(:xpath, '//span[../../a[@role="menuitem"]]')
    placements = placements.map(&:text)
    @client.find(:xpath, '//*[text()="All Ad Placements"]').click
    @prev_placement = 'All Ad Placements'
    @data = []
    placements.each do |placement|
      request_report placement
      extract_data_from_report placement
    end
  end

  def request_report(placement)
    @client.find(:xpath, "//*[text()=\"#{@prev_placement}\"]").click
    @client.find(:xpath, "//*[text()=\"#{placement}\"]").click
    @prev_placement = placement.match(/^(.+) \(\d+\)/).captures[0]
    sleep 1
  end

  def extract_data_from_report(placement)
    if @data.count == 0
      header = @client.find :xpath, '//table/thead/tr'
      @data << ['Placement'] + header.find_css('td,th').map { |td| td.visible_text }
    end
    data_str = @date.strftime '%a %b %d, %Y'
    rows = @client.find_all :xpath, "//table/*/tr[./td[text()=\"#{data_str}\"]]"
    return if rows.count == 0
    row = rows.first
    @data << [placement] + row.find_css('td,th').map { |td| td.visible_text }
  end
end