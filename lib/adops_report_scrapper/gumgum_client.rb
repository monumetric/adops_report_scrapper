require 'date'
require_relative 'base_client'

class AdopsReportScrapper::GumgumClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 7
    false
  end

  private

  def init_client
    fail 'please specify gumgum product. e.g. in_image' unless @options['product']
    @product = @options['product']
    super
  end

  def login
    @client.visit 'https://app.gumgum.com/login'
    @client.fill_in 'Email', :with => @login
    @client.fill_in 'Password', :with => @secret
    @client.click_button 'Login'
    begin
      @client.find :xpath, '//*[text()="Reporting"]'
    rescue Exception => e
      raise e, 'Gumgum login error'
    end
    cookies = @client.driver.cookies
    @client = HTTPClient.new
    @client.cookie_manager.cookies = cookies.values.map do |cookie|
      cookie = cookie.instance_variable_get(:@attributes)
      HTTP::Cookie.new cookie
    end
  end

  def scrap
    @date_str = @date.strftime('%Y-%m-%d')
    all_desktop_rows = get_parsed_report('ALL', '1')
    all_mobile_rows = get_parsed_report('ALL', '2')
    all_tablet_rows = get_parsed_report('ALL', '14')
    us_desktop_rows = get_parsed_report('US', '1')
    us_mobile_rows = get_parsed_report('US', '2')
    us_tablet_rows = get_parsed_report('US', '14')
    intl_desktop_rows = deduct_data_by_tracking_id(all_desktop_rows, us_desktop_rows)
    intl_mobile_rows = deduct_data_by_tracking_id(all_mobile_rows, us_mobile_rows)
    intl_tablet_rows = deduct_data_by_tracking_id(all_tablet_rows, us_tablet_rows)

    @data = [['day', 'zoneName', 'trackingId', 'inventoryImpressions', 'adImpressions', 'earnings', 'country', 'browser']]
    @data.concat(us_desktop_rows.map { |row| row.concat(['us', 'desktop']) })
    @data.concat(us_mobile_rows.map { |row| row.concat(['us', 'mobile']) })
    @data.concat(us_tablet_rows.map { |row| row.concat(['us', 'tablet']) })
    @data.concat(intl_desktop_rows.map { |row| row.concat(['intl', 'desktop']) })
    @data.concat(intl_mobile_rows.map { |row| row.concat(['intl', 'mobile']) })
    @data.concat(intl_tablet_rows.map { |row| row.concat(['intl', 'tablet']) })
  end

  def get_parsed_report(country, brwoser)
    response = @client.get("https://app.gumgum.com/p/reports/widget/table/metric/earnings/units/PRODUCT/target/#{@product}/start/#{@date_str}/end/#{@date_str}/zones/ALL/country/#{country}/browser/#{brwoser}/format/get.json")
    return JSON.parse(response.body)['rows'].map do |row|
      mapped_row = row.values_at(0, 1, 2, 3, 4, -1).map { |item| item['f'] }
      mapped_row[3] = mapped_row[3].to_i
      mapped_row[4] = mapped_row[4].to_i
      mapped_row[5] = mapped_row[5].to_f
      mapped_row
    end
  end

  def deduct_data_by_tracking_id(rows_to_deduct, rows_deduct_by)
    rows_to_return = rows_to_deduct.dup
    rows_to_return.map do |row_to_return|
      row_deduct_by = rows_deduct_by.select { |row_deduct_by| row_deduct_by[2] == row_to_return[2] }
      return row_to_return if row_deduct_by.empty?
      row_deduct_by = row_deduct_by[0]
      row_to_return[3] = row_to_return[3] - row_deduct_by[3]
      row_to_return[4] = row_to_return[4] - row_deduct_by[4]
      row_to_return[5] = row_to_return[5] - row_deduct_by[5]
      row_to_return
    end
  end
end
