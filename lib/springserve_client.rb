require 'date'
require_relative 'base_client'

class SpringserveClient < BaseClient
  private

  def login
    @client.visit 'http://video.springserve.com/'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Log in'
    begin
      @client.find :xpath, '//*[contains(text(),"Reporting")]'
    rescue Exception => e
      raise e, 'Springserve login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.find(:xpath, '//*[contains(text(),"Reporting")]').click
    @client.find(:xpath, '//*[contains(text(),"Create Reports")]').click

    # select date
    @client.find(:css, '#date_range_chosen').click
    @client.find(:xpath, '//*[text()="Yesterday"]').click

    @client.find(:css, '#dimensions_chosen').click
    @client.find(:xpath, '//*[text()="Country"]').click

    @client.find(:xpath, '//*[@value="Run Report"]').click

    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '#spinner_image')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 10
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//table[1]/*/tr'
    @data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }.reject { |row| row[0] == 'Total' }
  end
end