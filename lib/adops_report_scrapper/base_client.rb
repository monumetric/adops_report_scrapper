require 'date'
require 'phantomjs'
require 'capybara'
require 'capybara/poltergeist'

class AdopsReportScrapper::BaseClient
  # login: username, id, email, or api token
  # secret: password or api secret
  # options: {
  #   :date => (optional) default: yesterday
  # }
  def initialize(login, secret, options = nil)
    @login = login
    @secret = secret
    @options = options || {}
    @date = @options[:date] || Date.today.prev_day
  end

  # date: (optional)
  # return data in array of array, first array is the headers, no total included
  def get_data(date = nil)
    @date = date if date
    fail "specified date is not supported by this scrapper #{self.class.name}" unless date_supported?
    init_client
    login
    begin
      scrap
    rescue Exception => e
      begin
        before_quit_with_error
        logout
      rescue Exception => _e
        # do nothing
      end
      raise e
    end
    logout
    return @data
  end

  def init_client
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path, :timeout => 60)
    end
    Capybara.default_max_wait_time = 10
    @client = Capybara::Session.new(:poltergeist)
    @client.driver.browser.js_errors = false
    @client.driver.resize(1920, 985)
  end

  def login
    # do nothing by default
  end

  def scrap
    # do nothing by default
  end

  # logout can be optional
  def logout
    # do nothing by default
  end

  def before_quit_with_error
    @client.save_screenshot
  end

  # by default only support yesterday
  def date_supported?(date = nil)
    _date = date || @date
    return true if _date == Date.today.prev_day
    false
  end
end