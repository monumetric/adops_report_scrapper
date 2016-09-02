require 'date'
require_relative 'base_client'

class AdopsReportScrapper::TremorClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://console.tremorhub.com/ssp'
    @client.fill_in 'username', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Sign In'
    begin
      @client.find :xpath, '//*[text()="REPORTS"]'
    rescue Exception => e
      raise e, 'Tremor login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[text()="REPORTS"]').click
    @client.find(:xpath, '//*[text()="Custom"]').click
    sleep 1
    @client.find(:xpath, '//*[text()="New"]').click
    sleep 1
    # select group by
    @client.find(:css, '#availableFieldsListSearch').click
    @client.find(:xpath, '//*[text()="Supply Domain"]').click
    @client.find(:xpath, '//*[text()="Country"]').click
    @client.find(:xpath, '//*[text()="Ad Unit"]').click
    @client.find(:xpath, '//*[text()="Requests"]').click
    @client.find(:xpath, '//*[text()="Fills"]').click
    @client.find(:xpath, '//*[text()="Impressions"]').click
    @client.find(:xpath, '//*[text()="Completions"]').click
    @client.find(:xpath, '//*[text()="Total Net Revenue"]').click
    @client.find(:css, '.custom-report-dropdown-glyph.glyphicon-remove').click
    # select date
    @client.find(:css, '#customReportsDateRanges').click
    @client.find(:xpath, '//*[text()="Yesterday"]').click
    @client.click_button 'Run'
    sleep 10
    30.times do |_i| # wait 5 min
      begin
        @client.find(:xpath, '//*[text()="Please Hold"]')
      rescue Exception => e
        break
      end
      sleep 10
    end
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//table/*/tr'
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end
end