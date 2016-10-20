require 'date'
require_relative 'base_client'

class AdopsReportScrapper::TripleliftClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://console.triplelift.com/login'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Sign in'
    begin
      @client.find :xpath, '//*[text()="Reporting"]'
    rescue Exception => e
      raise e, 'Triplelift login error'
    end
  end

  def scrap
    @date_str = @date.strftime('%B %d, %Y')
    @client.find(:xpath, '//*[text()="Reporting"]').click
    wait_for_spin
    # byebug
    # @client.find(:xpath, '//button[contains(text(),"Last 7 days")]').click
    # @client.find(:xpath, '//a[contains(text(),"Yesterday")]').click


    
    @client.find(:xpath, '//button[../../div[contains(text(),"Publisher")]]').click
    @publishers = @client.find_all(:xpath, '//*[@ng-click="selectPublisher(pub)"]').to_a.map { |pub_elem| pub_elem.text(:all) }
    sleep 2
    @publishers = @client.find_all(:xpath, '//*[@ng-click="selectPublisher(pub)"]').to_a.map { |pub_elem| pub_elem.text(:all) }
    @client.find(:xpath, '//button[../../div[contains(text(),"Publisher")]]').click
    @data = []
    while @publishers.count > 0
      extract_data(@publishers.shift)
    end
  end

  def extract_data(publisher)
    10.times do
      @client.find(:xpath, '//*[text()="Reporting"]').click
      sleep 2
      @client.find(:xpath, '//button[../../div[contains(text(),"Publisher")]]').click
      index = -1 - @publishers.count(publisher)
      sleep 1
      @client.find_all(:xpath, "//*[text()=\"#{publisher}\"]")[index].click
      wait_for_spin

      return if @client.find_all(:xpath, '//*[text()="No data available for selected date range"]').count > 0

      @client.find(:xpath, '//*[@model="startDate"]//input').set @date_str
      sleep 1
      @client.find(:xpath, '//*[@model="endDate"]//input').set @date_str
      sleep 1
      @client.find(:xpath, '//button[../../div[contains(text(),"Group by")]]').click
      @client.find(:xpath, '//*[text()="Date and Placement"]').click
      wait_for_spin

      return if @client.find_all(:xpath, '//*[text()="No data available for selected date range"]').count > 0

      rows = @client.find_all :xpath, '//table/*/tr'
      rows = rows.to_a
      rows.shift
      header = rows.shift
      n_data = rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
      if n_data[-1][1].empty?
        @client.evaluate_script 'window.location.reload()'
        next
      end
      if @data.count == 0
        n_header = header.find_css('td,th').map { |td| td.visible_text }
        @data << n_header
      end
      @data += n_data
      break
    end
  end

  def wait_for_spin
    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '.spinner')
      rescue Exception => e
        break
      end
      sleep 5
    end
    sleep 2
  end
end