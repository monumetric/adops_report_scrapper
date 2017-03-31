require 'date'
require_relative 'base_client'

class AdopsReportScrapper::TremorClient < AdopsReportScrapper::BaseClient
  def init_client
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, :browser => :firefox)
    end
    @client = Capybara::Session.new(:selenium)
  end

  private

  def login
    @client.visit 'https://console.tremorhub.com/ssp'
    @client.driver.browser.manage.window.resize_to(1366,768)
    @client.fill_in 'username', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Sign In'
    begin
      retries ||= 0
      sleep 1
      @client.find :xpath, '//*[text()="REPORTS"]'
    rescue Exception => e
      retry if (retries += 1) < 10
      raise e, 'Tremor login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[text()="REPORTS"]').click
    sleep 1
    @client.find(:xpath, '//*[text()="REPORTS"]').click
    sleep 1
    @client.find(:xpath, '//*[text()="Custom"]').click
    sleep 1
    @client.find(:xpath, '//*[text()="New"]').click
    sleep 1

    # select date
    @client.find(:css, '#customReportsDateRanges').click
    @client.find(:xpath, '//*[text()="Yesterday"]').click
    @client.find(:css, '#timezone').click
    sleep 1
    @client.find_all(:xpath, '//div[text()="Eastern Standard Time"]').first.click

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
    @client.execute_script('window.scrollTo(0,0)')
    @client.click_button 'Run'
    sleep 10
    flag_holding = true
    60.times do |_i| # wait 10 min
      begin
        @client.find(:xpath, '//*[text()="Please Hold"]')
      rescue Exception => e
        flag_holding = false
        break
      end
      sleep 10
    end
    fail 'Tremor report taking too long. Abort' if flag_holding
  end

  def extract_data_from_report
    page = Nokogiri::HTML @client.html
    rows = page.xpath '//table[@id="DataTables_Table_1"]/*/tr'
    @data = rows.map { |tr| tr.css('td,th').map { |td| td.text } }
  end
end
