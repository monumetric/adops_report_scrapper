require 'date'
require_relative 'base_client'
require 'rest-client'
require 'httpclient'

class AdopsReportScrapper::RhythmoneClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 3
    false
  end

  private

  def init_client
    fail 'please specify rhythmone client_id' unless @options['client_id']
    fail 'please specify rhythmone client_secret' unless @options['client_secret']
    fail 'please specify rhythmone publisher_id' unless @options['publisher_id']
    @client_id = @options['client_id']
    @client_secret = @options['client_secret']
    @publisher_id = @options['publisher_id']
  end

  def before_quit_with_error
  end

  def login
    response = RestClient.post 'https://api.portal.rhythmone.com/v1/users/login', client_id: @client_id, client_secret: @client_secret, grant_type: 'password', password: @secret, username: @login
    token_obj = JSON.parse response.body
    @access_token = token_obj['access_token']
  end

  def scrap
    date_str = @date.strftime('%Y%m%d')
    data_obj = nil
    5.times do
      response = HTTPClient.get("https://api.portal.rhythmone.com/v1/publishers/#{@publisher_id}/reports/standard_report", { ad_dimension: 0, endDate: date_str, endDateType: 1, groupBy1: 1, groupByTimePeriodType: 1, rmp_placement: 0, startDate: date_str, startDatePredefined: 0, startDateType: 1 }, { 'Authorization' => "Bearer #{@access_token}" })
      data_obj = JSON.parse response.body
      break if data_obj.is_a? Array
      sleep 5
    end
    @data = data_obj
  end
end