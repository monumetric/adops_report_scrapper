require 'date'
require_relative 'base_client'

class AdopsReportScrapper::SonobiClient < AdopsReportScrapper::BaseClient
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date >= Date.today - 2
    false
  end

  private

  def init_client
    fail 'please specify sonobi key' unless @options['key']
    fail 'please specify sonobi code' unless @options['code']
    fail 'please specify sonobi userid' unless @options['userid']
    @key = @options['key']
    @code = @options['code']
    @userid = @options['userid']
    super
  end

  def before_quit_with_error
  end

  def login
    @client.visit 'https://jetstream.sonobi.com/welcome/login.php'
    @client.fill_in 'user name', :with => @login
    @client.fill_in 'password', :with => @secret
    @client.click_button 'Log In'
    begin
      @client.find :xpath, '//*[text()="dashboard"]'
    rescue Exception => e
      raise e, 'Sonobi login error'
    end
    cookies = @client.driver.cookies
    @client.driver.close_window('0')

    @client = HTTPClient.new
    @client.cookie_manager.cookies = cookies.values.map do |cookie|
      cookie = cookie.instance_variable_get(:@attributes)
      HTTP::Cookie.new cookie
    end
  end

  def scrap
    @data = []
    request_report(:us)
    extract_data_from_report(:us)
    request_report(:intl)
    extract_data_from_report(:intl)
  end

  def request_report(country)
    date_str = @date.strftime('%Y-%m-%d')
    is_us = country == :us

    response = @client.post('https://jetstream.sonobi.com/public/', cm: 'category.list', key: @key, code: @code, _userid: @userid, _parentid: 'locations')
    countries = JSON.parse response.body

    report_body = {
      '_userid': @userid,
      '_country' => is_us ? 'US' : 'AL,DZ,AO,AI,AQ,AG,AP,AU,AT,AZ,BS,BB,BE,BZ,BM,BT,BO,BR,IO,BG,KH,CM,CA,CV,KY,CF,TD,CL,CN,CO,CG,CD,CR,CU,CY,DK,DM,DO,EG,EU,FJ,FI,FR,GM,DE,GR,GL,HT,VA,HN,HK,IS,IN,ID,IR,IQ,IE,IL,IT,JM,JP,JO,KZ,KP,KR,KW,LV,LB,LR,LY,LU,MG,MW,MY,ML,MT,MU,MX,MC,MN,ME,MA,MZ,NA,NP,NL,NZ,NI,NG,NO,OM,PK,PA,PH,PL,PR,QA,RO,RU,RW,SM,SA,SG,SK,SI,SO,ZA,ES,LK,SD,SE,CH,SY,TW,TJ,TH,TR,UG,AE,GB,UM,UY,UZ,VN,VG,VI,EH,YE,ZM,ZW',
      'groupby' => 'day',
      'row_per' => '_date,_placementid,_siteid',
      'columns' => '_date,_placementid_name,_siteid_name,_impression_count,_impression_count_viewed,_impression_count_clicked,_unfilled_impressions,_revenue,_ecpm,_device_type,_placementid,_siteid',
      'tz_offset' => 'UTC',
      '__column_info' => '[{\"name\":\"_date\",\"label\":\"Date\",\"no_limit\":true,\"tip\":\"Shows+the+date+that+impressions+were+served+on\"},{\"name\":\"_placementid_name\",\"label\":\"Placement\",\"tip\":\"Shows+the+Placement+name+that+impressions+were+served+on\"},{\"name\":\"_siteid_name\",\"label\":\"Site\",\"tip\":\"Shows+the+name+of+the+site+that+impressions+were+served+on\"},{\"name\":\"_impression_count\",\"label\":\"Impressions\",\"format\":true,\"tip\":\"The+number+of+impressions+that+were+served\"},{\"name\":\"_impression_count_viewed\",\"label\":\"Viewable+Impressions\",\"format\":true,\"tip\":\"The+number+of+times+that+the+ad+was+viewed\"},{\"name\":\"_impression_count_clicked\",\"label\":\"Clicks\",\"format\":true,\"tip\":\"The+number+of+clicks+that+were+recorded\"},{\"name\":\"_unfilled_impressions\",\"label\":\"Unfilled+Impressions\",\"format\":true,\"tip\":\"The+number+of+impressions+could+not+be+served+due+to+ad+server+decisioning\"},{\"name\":\"_revenue\",\"label\":\"Revenue\",\"format\":\"currency\",\"pre\":\"$\",\"tip\":\"Gross+revenue+of+impressions+served\"},{\"name\":\"_ecpm\",\"label\":\"Delivered+CPM\",\"format\":\"currency\",\"pre\":\"$\",\"tip\":\"Average+CPM+of+impressions+served\"},{\"name\":\"_device_type\",\"label\":\"Device+Type\",\"tip\":\"Device+Types+include:+Desktop,+Mobile\"}]'
    }

    response = @client.post('https://jetstream.sonobi.com/public/', cm: 'report.request', key: @key, code: @code, _report: report_body.to_json, _report_type: 'publisher_report', _report_origin: 'publisher_reporting', _range: 'custom', _range_start_date: date_str, _range_end_date: date_str)
    report = JSON.parse response.body
    report_id = report['package']['_reportid']
    sleep 5

    30.times do # pull report 30 times
      response = @client.post('https://jetstream.sonobi.com/public/', cm: 'report.get', key: @key, code: @code, _reportid: report_id, _wait: 'true')
      report = JSON.parse response.body
      report_status = report['package']['status']
      case report_status
      when 'complete'
        break
      when 'processing'
        sleep 10
      else
        fail 'sonobi scrapper: unknown report status'
      end
    end

    @response = response
  end

  def extract_data_from_report(country)
    report = JSON.parse @response.body
    rows = report['package']['result']
    if @data.count == 0
      @data << ['Date', 'Placement', 'Site', 'Impressions', 'Clicks', 'Views', 'Unfilled Impressions', 'Revenue', 'Device Type', 'Country']
    end
    @data += rows.map do |row|
      n_keys = ["_date", "_placementid_name", "_siteid_name", "_impression_count", "_impression_count_clicked", "_impression_count_viewed", "_unfilled_impressions", "_revenue", "_device_type"]
      n_row = n_keys.map { |k| row[k] }
      n_row << country.to_s.upcase
      n_row
    end
  end
end
