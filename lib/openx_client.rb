require 'date'
require_relative 'base_client'

class OpenxClient < BaseClient
  REPORT_NAME = 'Ad Server Report for ad_report_scrapper'

  private

  def login
    @client.driver.resize 1920, 700
    fail 'please specify openx account prefix' unless @options['account_prefix']
    @account_prefix = @options['account_prefix']
    @client.visit "http://#{@account_prefix}.openx.net/"
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Submit'
    begin
      @client.find :xpath, '//*[text()="Reports"]'
    rescue Exception => e
      raise e, 'Openx login error'
    end
  end

  def scrap
    request_report
  end

  def request_report
    @client.visit 'http://cmci-ui.openx.net/#/reports?tab=my_reports'
    sleep 5

    begin
      tries ||= 6
      @client.find(:css, '#report_frame')
    rescue Exception => e
      retry unless (tries -= 1).zero?
    end

    create_report_if_not_exist
    
    @client.within_frame @client.find(:css, '#report_frame') do
      @client.find(:xpath, "//a[text()=\"#{REPORT_NAME}\"]").click

      begin
        tries ||= 6
        @client.find(:css, '.myFrame')
      rescue Exception => e
        retry unless (tries -= 1).zero?
      end
      
      @client.within_frame @client.find(:css, '.myFrame') do
        begin
          tries ||= 18
          @client.find(:xpath, '//option[text()="500"]')
        rescue Exception => e
          retry unless (tries -= 1).zero?
        end
        
        @client.find(:xpath, '//option[text()="500"]').select_option
        extract_data_from_report
      end
    end
    sleep 5
  end

  def create_report_if_not_exist
    @client.within_frame @client.find(:css, '#report_frame') do
      ready_elem = nil
      begin
        tries ||= 6
        ready_elem = @client.find(:xpath, '//*[text()="Preconfigured Reports"]')
      rescue Exception => e
        retry unless (tries -= 1).zero?
      end

      fail 'openx report page not ready' unless ready_elem
    
      if @client.find_all(:xpath, "//a[text()=\"#{REPORT_NAME}\"]").count == 0

        # create report if not exist
        @client.find(:xpath, '//*[contains(text(),"Create Report")]').click
        @client.find(:xpath, '//li/*[text()="Ad Server Report"]').click

        begin
          tries ||= 6
          @client.find(:css, '.myFrame')
        rescue Exception => e
          retry unless (tries -= 1).zero?
        end
        
        @client.within_frame @client.find(:css, '.myFrame') do

          @client.find(:xpath, '//*[text()="Last Seven Days"]').click
          @client.find(:xpath, '//*[text()="Yesterday"]').click
          @client.find(:xpath, '//*[@value="Next"]').trigger('click')
          sleep 2

          @client.find(:xpath, '//*[text()="Ad Unit"]').click
          @client.find(:xpath, '//img[../../td//*[text()="User"]]').click
          @client.find(:xpath, '//*[text()="Country"]').click
          @client.find(:xpath, '//*[text()="Device Category"]').click
          @client.find(:xpath, '//*[@value="Next"]').trigger('click')
          sleep 2
          
          @client.find(:xpath, '//*[text()="Paid Impressions"]').click
          @client.find(:xpath, '//*[text()="Impressions Delivered"]').click
          @client.find(:xpath, '//*[text()="Ad Requests"]').click
          @client.find(:xpath, '//img[../../td//*[text()="Revenue"]]').click
          @client.find(:xpath, '//*[text()="Publisher Revenue"]').click
          @client.find(:xpath, '//img[../../td//*[text()="Clicks"]]').click
          @client.find(:xpath, '//div[text()="Clicks"]').click
          @client.find(:xpath, '//*[@value="Next"]').trigger('click')
          sleep 2

          @client.find(:xpath, '//*[@value="Save"]').trigger('click')

          begin
            tries ||= 6
            @client.find(:xpath, '//*[text()="Save Report"]')
          rescue Exception => e
            retry unless (tries -= 1).zero?
          end
          
          @client.fill_in 'saveAsReportName', :with => REPORT_NAME
          @client.find(:xpath, '//*[@value="Save Report"]').trigger('click')

          begin
            tries ||= 6
            @client.find(:xpath, '//*[text()="Report Saved"]')
          rescue Exception => e
            retry unless (tries -= 1).zero?
          end
          
          @client.find(:xpath, '//*[text()="Back to My Reports"]').trigger('click')
        end
        sleep 2
      end
    end
  end

  def extract_data_from_report
    @data = []
    loop do
      18.times do
        sleep 10
        break if @client.find_all(:xpath, '//table[@id="table_UniqueReportID"]/*/tr').count > 0
      end
      rows = @client.find_all :xpath, '//table[@id="table_UniqueReportID"]/*/tr'
      rows = rows.to_a
      header = rows.shift
      if @data.count == 0
        n_header = header.find_css('td,th').map { |td| td.visible_text }
        @data << n_header
      end
      @data += rows.map { |tr| tr.find_css('td,th').map { |td| td.visible_text } }
      pagee = @client.find(:xpath, '//*[contains(text(),"Showing rows")]').text.match(/-(\d+) of (\d+)\./).captures
      break if pagee[0] == pagee[1]
      @client.find_all(:css, '#paginationNext').first.trigger('click')
    end
  end
end