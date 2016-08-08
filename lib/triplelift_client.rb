require 'date'
require_relative 'base_client'

class TripleliftClient < BaseClient
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
    @client.find(:xpath, '//*[@ng-if="publishers.length > 1"]').click
    @publishers = @client.find_all(:xpath, '//*[@ng-click="selectPub(pub)"]').to_a.map { |pub_elem| pub_elem.text(:all) }
    @client.find(:xpath, '//*[@ng-if="publishers.length > 1"]').click
    @data = []
    while @publishers.count > 0
      extract_data(@publishers.shift)
    end
  end

  def extract_data(publisher)
    @client.find(:xpath, '//*[@ng-if="publishers.length > 1"]').click
    index = -1 - @publishers.count(publisher)
    sleep 1
    @client.find_all(:xpath, "//*[text()=\"#{publisher}\"]")[index].click
    @client.find(:xpath, '//*[text()="Reporting"]').click
    @client.find(:xpath, '//*[@model="startDate"]//input').set @date_str
    @client.find(:xpath, '//*[@model="endDate"]//input').set @date_str
    @client.find(:xpath, '//button[../../div[contains(text(),"Group by")]]').click
    @client.find(:xpath, '//*[text()="Date and Placement"]').click
    sleep 3

    return if @client.find_all(:xpath, '//*[text()="No data available for selected date range"]').count > 0

    rows = @client.find_all :xpath, '//table/*/tr'
    rows = rows.to_a
    rows.shift
    header = rows.shift
    if @data.count == 0
      n_header = header.find_css('td,th').map { |td| td.visible_text }
      @data << n_header
    end
    @data += rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
  end
end