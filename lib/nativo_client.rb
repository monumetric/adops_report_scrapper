require 'date'
require_relative 'base_client'

class NativoClient < BaseClient
  private

  def login
    @client.visit 'https://admin.nativo.net/'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Log In'
    begin
      @client.find :xpath, '//*[text()="Reports"]'
    rescue Exception => e
      raise e, 'Nativo login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.click_link 'Reports'
    @client.click_link 'Marketplace Campaigns'

    @client.find(:css, '.date-range').click
    @client.find(:xpath, '//*[text()="Yesterday"]').click

    @client.check 'Publisher'
    @client.check 'Device'

    @client.check 'Clicks'
    @client.check 'Publisher Revenue'
    @client.check 'Video Views'
    @client.check 'Video Views to 100%'
    sleep 1
    wait_for_loading
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//div/table/*[self::thead|self::tbody]/tr'
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end

  def wait_for_loading
    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '.loading')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 1
  end
end