require 'date'
require_relative 'base_client'

# please ensure that all live widgets have distinct name

class ContentadClient < BaseClient
  def init_client
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
    end
    Capybara.default_max_wait_time = 3
    @client = Capybara::Session.new(:poltergeist)
    @client.driver.browser.js_errors = false
    @client.driver.resize(1920, 985)
  end

  private

  def login
    @client.visit 'https://www.content.ad/Login.aspx'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Log In'
    begin
      @client.find :xpath, '//*[text()="Widget Report"]'
    rescue Exception => e
      raise e, 'Contentad login error'
    end
  end

  def scrap
    @client.find(:xpath, '//option[text()="Yesterday"]').select_option
    @client.click_link 'Apply'
    wait_for_loading

    @client.find(:xpath, '//span[text()="Widgets"]').click
    wait_for_loading
    
    rows = @client.find_all :xpath, '//table/tbody/tr'
    widgets = rows.map do |row|
      row = row.find_css('td').map { |td| td.visible_text }
      { widget_name: row[0], domain_name: row[1] }
    end

    @client.visit 'https://app.content.ad/Publisher/DeviceGeoReport'
    @client.find(:xpath, '//option[text()="Yesterday"]').select_option
    @client.click_link 'Apply'
    wait_for_loading

    @data = []
    widgets.each do |widget|
      request_report widget
    end
  end

  def request_report(widget)
    widget_options = @client.find(:xpath, "//option[text()=\"#{widget[:widget_name]}\"]").select_option
    @client.click_link 'Apply'
    wait_for_loading
    extract_data_from_report widget
  end

  def extract_data_from_report(widget)
    rows = @client.find_all :xpath, '//table/*/tr'
    rows = rows.to_a
    header = rows.shift
    if @data.count == 0
      header = ['Date', 'Domain', 'Widget'] + header.find_css('td,th').map { |td| td.visible_text }
      @data << header
    end
    rows.pop
    @data += rows.map do |tr|
      row = tr.find_css('td,th').map do |td|
        td.visible_text
      end
      [@date.to_s, widget[:domain_name], widget[:widget_name]] + row
    end
  end

  def wait_for_loading
    18.times do |_i| # wait 3 min
      begin
        @client.find(:css, '#loadingProgress')
      rescue Exception => e
        break
      end
      sleep 3
    end
    sleep 1
  end
end