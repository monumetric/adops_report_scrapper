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
    scrap
  end

  def scrap
    # do nothing by default
  end
end