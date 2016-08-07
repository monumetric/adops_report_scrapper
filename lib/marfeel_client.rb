require 'date'
require_relative 'base_client'

class MarfeelClient < BaseClient
  private

  def login
    @client.visit 'https://insight.marfeel.com/hub/login'
    @client.fill_in 'j_username', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Login'
    begin
      @client.find :xpath, '//*[text()="REPORTING"]'
    rescue Exception => e
      raise e, 'Marfeel login error'
    end
  end

  def scrap
    request_report
    extract_data_from_report
  end

  def request_report
    @client.visit 'https://insight.marfeel.com/hub/insight/reporting?date=1d'
    sleep 1
  end

  def extract_data_from_report
    rows = @client.find_all :xpath, '//table/*/tr'
    n_rows = rows.map do |tr|
      tr.find_css('td,th').map do |td|
        datum = td.visible_text
        if datum.end_with? ' K'
          datum = datum.to_f * 1_000
        elsif datum.end_with? ' M'
          datum = datum.to_f * 1_000_000
        end
        datum.to_s
      end
    end
    n_rows[0][0] = 'Site'
    site = nil
    l = n_rows[0].count
    @data = n_rows.map do |row|
      if row.count == l
        row[0] = row[0].split(' $')[0]
        site = row[0]
      else
        row.unshift site
      end
      row
    end
    (@data.count - 1).times do |i|
      i.even? ? @data[i+1].unshift('Smartphone') : @data[i+1].unshift('Tablet')
    end
    @data[0].unshift 'Device'
  end
end