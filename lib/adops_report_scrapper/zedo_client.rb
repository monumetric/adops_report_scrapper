require 'date'
require 'httpclient'
require 'nokogiri'
require_relative 'base_client'

class AdopsReportScrapper::ZedoClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 3
    false
  end

  private

  def init_client
    fail 'please specify zedo network_id' unless @options['network_id']
    @network_id = @options['network_id']
    @client = HTTPClient.new
  end

  def login
    response = @client.post('https://target.zedo.com/servlet/LoginServlet', uid: @login, pwd: @secret, rem: 0, from: 'login', fromSupport: 'no', fromEmail: 'false')
    doc = Nokogiri::HTML(response.body)
    profit_elem_href = doc.xpath('//a[text()="Profit"]/@href').first.value
    @referer_url = "https://target.zedo.com#{profit_elem_href}"
    @client.get(@referer_url)
  end

  def scrap
    date_str = date.strftime('%m/%d/%Y')

    body = {
      step: 'submit', event_key: 'profit_rpt', mobilereport: 'off', scheduler: 'NO', schedule_event_key: '', time_period: '', reportTime: '', reporttypeName: 'Publisher Report', dateDifference: '', drilldown: 'false', domain: '', report: '0', tperiod: 'summary', timePeriod: 'summary', i18n_startDate: date_str, startDate: date_str, i18n_endDate: date_str, endDate: date_str, revenueTypeFilter: '-1', actionTypeFilter: 'post_total', publisher: '-1', channel: '-1', dimension: '-1', pageTime: Time.now.strftime('%s%3N'), nwtId: @network_id
    }
    header = { Referer: @referer_url }

    response = @client.post('https://target.zedo.com/Main?reporttype=mbc&reportname=Quick_Profit_Report', body: body, header: header)

    doc = Nokogiri::HTML(response.body)
    header = doc.xpath('//table[@id="table-1"]/thead/tr/td').map { |td| td.text.strip }
    @data = [header]
    rows = doc.xpath('//table[@id="table-1"]/tbody/tr')
    @data += rows.map { |tr| tr.css('td,th').map { |td| td.text.strip } }
  end
end