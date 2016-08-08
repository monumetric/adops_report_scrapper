require 'date'
require_relative 'base_client'

class BrightrollClient < BaseClient
  private

  def login
    @client.visit 'https://login.brightroll.com/login'
    @client.fill_in 'user_login', :with => @login
    @client.fill_in 'user_password', :with => @secret
    @client.click_button 'Sign In'
    begin
      @client.find :xpath, '//*[text()="Tags"]'
    rescue Exception => e
      raise e, 'Brightroll login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[text()="Tags"]').click
    @client.find(:css, '.details-date-filter').click
    # select date
    @client.find(:xpath, '//*[text()="Yesterday"]').click

    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '.bubble-loader.bubble-loader-3')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 10
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//table[1]/*/tr'
    rows = rows.to_a
    rows.delete_at 1
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end
end