require 'date'
require_relative 'base_client'

class AdiplyClient < BaseClient
  private

  def login
    @client.visit 'http://pub.adiply.com/login'
    @client.fill_in '_username', :with => @login
    @client.fill_in '_password', :with => @secret
    @client.click_button 'Sign me in'
    begin
      @client.find :xpath, '//*[text()="Go"]'
    rescue Exception => e
      raise e, 'Adiply login error'
    end
  end

  def scrap
    zones = @client.find_all(:css, '#AppBundle_filtersForm_zone > option')
    zones = zones.to_a
    zones.shift
    zones = zones.map { |zone| zone.text }
    @client.find(:xpath, '//a[contains(text(),"Performance")]').click
    @client.find(:css, '.dr-presets').click
    @client.find(:xpath, '//*[contains(text(),"Last 30 days")]').click
    @data = []
    zones.each do |zone|
      extract_data zone
    end
  end

  def extract_data(zone)
    @client.find(:xpath, "//option[text()=\"#{zone}\"]").select_option
    @client.find(:xpath, '//*[text()="Go"]').click
    sleep 2
    date_str = @date.strftime '%m/%d/%Y'
    if @data.count == 0
      header = @client.find_all(:xpath, '//table/thead/tr/th').map { |th| th.text }
      header[-1] = 'Zone'
      @data << header
    end
    tds = @client.find_all :xpath, "//td[../td[contains(text(),\"#{date_str}\")]]"
    row = tds.map { |td| td.text }
    row[-1] = zone
    row[0] = date_str
    @data << row
  end
end