require 'date'
require_relative 'base_client'
require 'nokogiri'

class ConversantClient < BaseClient
  private

  def login
    @client.visit 'https://admin.valueclickmedia.com/corp/login'
    @client.fill_in 'user_name', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Submit'
    begin
      @client.find :xpath, '//*[contains(text(),"Reports")]'
    rescue Exception => e
      raise e, 'Conversant login error'
    end
  end

  def scrap
    @client.click_link 'Earnings'

    sites = @client.find_all(:css, '#search-site_id > option')
    n_sites = []
    sites.each do |site|
      site_id = site[:value].to_i
      next if site_id <= 0
      site_name = site.text
      n_sites << { site_id: site_id, site_name: site_name }
    end

    @data = [['Site', 'Device', 'Country', 'Impressions', 'Clicks', 'Earnings']]
    n_sites.each do |site|
      extract_data site
    end
  end

  def extract_data(site)
    d_us_datum = get_line_data(site, :desktop, :us)
    m_us_datum = get_line_data(site, :mobile, :us)
    d_all_datum = get_line_data(site, :desktop, :all)
    m_all_datum = get_line_data(site, :mobile, :all)
    d_intl_datum = d_all_datum.zip(d_us_datum).map { |x, y| x - y }
    m_intl_datum = m_all_datum.zip(m_us_datum).map { |x, y| x - y }

    d_us_datum = [site[:site_name], 'Desktop', 'US'] + d_us_datum
    m_us_datum = [site[:site_name], 'Mobile', 'US'] + m_us_datum
    d_intl_datum = [site[:site_name], 'Desktop', 'Intl'] + d_intl_datum
    m_intl_datum = [site[:site_name], 'Mobile', 'Intl'] + m_intl_datum

    [d_us_datum, m_us_datum, d_intl_datum, m_intl_datum].each do |datum|
      next if datum[2..-1] == [0,0,0]
      @data << datum
    end
  end

  def get_line_data(site, device, country)
    date_str = @date.strftime '%Y-%m-%d'
    supply_type_id_map = { desktop: 1, mobile: 2 }
    country_id_map = { all: 0, us: 254 }
    @client.visit "https://pub.valueclickmedia.com/reports/earnings/detailed_media_grid?start_date=#{date_str}&end_date=#{date_str}&site_id=#{site[:site_id]}&media_type_id=&supply_type_id=#{supply_type_id_map[device]}&country_id=#{country_id_map[country]}"
    doc = Nokogiri::XML(@client.body)
    cells = doc.css('cell')
    return [cells[1].content.to_i, cells[2].content.to_i, cells[-1].content.to_f] # [imp, click, earning]
  end
end