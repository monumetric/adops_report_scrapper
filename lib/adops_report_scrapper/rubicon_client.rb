require 'date'
require_relative 'base_client'
require 'rest-client'

class AdopsReportScrapper::RubiconClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date < Date.today
    false
  end

  def init_client
    fail 'please specify rubicon account id' unless @options['account_id']
    @account_id = @options['account_id']
  end

  def before_quit_with_error
  end

  private

  def scrap
    date_str = date.strftime '%F'

    response = RestClient::Request.execute method: :get, url: "https://api.rubiconproject.com/analytics/v1/report/?account=publisher/#{@account_id}&start=#{date_str}T00:00:00-07:00&end=#{date_str}T23:59:59-08:00&dimensions=date,site,country,device_type,ad_format&metrics=bid_requests,paid_impression,revenue", user: @login, password: @secret

    data = JSON.parse response.body
    @data = [data['data']['items'].first.keys]
    @data += data['data']['items'].reject{ |item| item['date'] != date_str }.map(&:values)
  end
end
