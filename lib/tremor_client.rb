require 'date'
require_relative 'base_client'

class TremorClient < BaseClient
  def scrap
    puts @login
    puts @secret
    puts @date
  end
end