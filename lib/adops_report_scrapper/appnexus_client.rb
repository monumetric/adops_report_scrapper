require 'date'
require_relative 'base_client'
require 'rest-client'
require 'csv'

class AdopsReportScrapper::AppnexusClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 7
    false
  end

  def init_client
  end

  def before_quit_with_error
  end

  private

  def scrap
    date_str = date.strftime '%F'

    response = RestClient.post 'https://api.appnexus.com/auth', { 'auth' => { 'username' => @login, 'password' => @secret } }.to_json, { content_type: :json, accept: :json }
    response_data = JSON.parse(response.body)
    token = response_data['response']['token']

    response = RestClient.post 'http://api.appnexus.com/report', { 'report' => { 'report_type' => 'network_analytics', 'report_interval' => 'last_7_days', 'columns' => %w(day publisher_name site_name geo_country supply_type imp_requests imps clicks total_convs revenue) } }.to_json, { content_type: :json, accept: :json, authorization: token }
    response_data = JSON.parse(response.body)
    report_id = response_data['response']['report_id']

    sleep 10

    response = RestClient.get "http://api.appnexus.com/report?id=#{report_id}", { authorization: token }
    response_data = JSON.parse(response.body)
    fail 'appnexus report failed' unless response_data['response']['execution_status'] == 'ready'

    response = RestClient.get "http://api.appnexus.com/report-download?id=#{report_id}", { authorization: token }
    @data = CSV.parse(response.body).select { |row| row[0] == 'day' || (row[0] == date_str && row[5].to_i > 0) }
  end
end
