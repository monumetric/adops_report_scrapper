require 'date'
require 'phantomjs'
require 'capybara'
require 'capybara/poltergeist'

class BaseClient
  # login: username, id, email, or api token
  # secret: password or api secret
  # options: {
  #   :date => (optional) default: yesterday
  # }
  def initialize(login, secret, options = {})
    @login = login
    @secret = secret
    @date = options[:date] || Date.today.prev_day
    @options = options
  end

  # date: (optional)
  # return data in array of array, first array is the headers, no total included
  def get_data(date = nil)
    @date = date if date
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

  def workflow
    
  end

  def init_client
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
    end
    Capybara.default_max_wait_time = 10
    @client = Capybara::Session.new(:poltergeist)
    @client.driver.browser.js_errors = false
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
end