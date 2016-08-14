require 'date'
require_relative 'base_client'
require 'httpclient'
require 'roo'

class AdopsReportScrapper::LiveintentClient < AdopsReportScrapper::BaseClient
  private

  def login
    @client.visit 'https://lfm.liveintent.com/'
    @client.fill_in 'username', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Login'
    begin
      @client.find :xpath, '//*[text()="Analysis"]'
    rescue Exception => e
      raise e, 'Liveintent login error'
    end
  end

  def scrap
    request_report
  end

  def request_report
    @client.find(:xpath, '//*[text()="Analysis"]').click
    @client.find(:xpath, '//*[contains(text(),"Reporting")]').click
    @client.find(:xpath, '//*[text()="New"]').click
    sleep 1
    @client.find(:xpath, '//*[text()="Publisher ID"]').click
    @client.find(:xpath, '//*[text()="Ad Slot ID"]').click
    @client.find(:xpath, '//*[text()="Add additional split"]').click
    @client.find(:xpath, '//*[text()="Year/Month"]').click
    @client.find(:xpath, '//*[text()="Device Type (inexact values)"]').click
    @client.find(:xpath, '//input[@id="intervalBegin"]').set @date.strftime('%Y-%m-%d / %Y-%m-%d')
    @client.click_button 'Download'
    wait_for_spin

    request_data = @client.driver.network_traffic.last.instance_variable_get(:@data)
    report_file_url = @client.driver.network_traffic.last.url

    cookies = @client.driver.cookies
    @client = HTTPClient.new
    @client.cookie_manager.cookies = cookies.values.map do |cookie|
      cookie = cookie.instance_variable_get(:@attributes)
      HTTP::Cookie.new cookie
    end

    header = {
      Accept: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      Referer: 'https://lfm.liveintent.com/reporting/',
      Origin: 'https://lfm.liveintent.com',
      'User-Agent': 'Mozilla/5.0 (Unknown; Linux x86_64) AppleWebKit/538.1 (KHTML, like Gecko) PhantomJS/2.1.1 Safari/538.1',
      'Content-Type': 'application/json',
    }

    @client.receive_timeout = 300
    response = @client.post(report_file_url, header: header, body: request_data['postData'] )

    tmpfile = Tempfile.new('liveintent.xlsx')
    begin
      tmpfile.binmode
      tmpfile.write(response.body)
      tmpfile.close

      xlsx = Roo::Spreadsheet.open(tmpfile.path, extension: :xlsx)
      extract_data_from_report xlsx
    ensure
      tmpfile.close
      tmpfile.unlink   # deletes the temp file
    end

  end

  def extract_data_from_report(xlsx)
    @data = xlsx.to_a.reject { |row| row[1] == '(totals)' || row[0] == '(totals)' }
  end

  def wait_for_spin
    30.times do |_i| # wait 5 min
      begin
        @client.find(:css, '.fa.fa-spinner.fa-spin')
      rescue Exception => e
        break
      end
      sleep 10
    end
    sleep 5
  end
end
