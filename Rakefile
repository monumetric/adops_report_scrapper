require 'bundler/gem_tasks'
require 'yaml'
require 'csv'
require 'date'

require 'byebug'

desc 'Collect all data'
task :all => [:tremor, :brightroll, :yellowhammer, :aol, :fourninefive] do
  puts 'all'
end

desc 'Collect tremor data'
task :tremor do
  if File.file?(get_yesterdays_file_path(:tremor))
    puts 'tremor data already scraped'
    next
  end
  puts 'working on tremor'
  require_relative 'lib/tremor_client'
  cred = YAML.load_file('secret.yml')['tremor']
  data = TremorClient.new(cred['login'], cred['secret']).get_data
  write_csv(:tremor, data)
end

desc 'collect brightroll data'
task :brightroll do
  if File.file?(get_yesterdays_file_path(:brightroll))
    puts 'brightroll data already scraped'
    next
  end
  puts 'working on brightroll'
  require_relative 'lib/brightroll_client'
  cred = YAML.load_file('secret.yml')['brightroll']
  data = BrightrollClient.new(cred['login'], cred['secret']).get_data
  write_csv(:brightroll, data)
end

desc 'Collect yellowhammer data'
task :yellowhammer do
  if File.file?(get_yesterdays_file_path(:yellowhammer))
    puts 'yellowhammer data already scraped'
    next
  end
  puts 'working on yellowhammer'
  require_relative 'lib/springserve_client'
  cred = YAML.load_file('secret.yml')['yellowhammer']
  data = SpringserveClient.new(cred['login'], cred['secret']).get_data
  write_csv(:yellowhammer, data)
end

desc 'Collect adaptv data'
task :adaptv do
  if File.file?(get_yesterdays_file_path(:adaptv))
    puts 'adaptv data already scraped'
    next
  end
  puts 'working on adaptv'
  require_relative 'lib/adaptv_client'
  cred = YAML.load_file('secret.yml')['adaptv']
  data = AdaptvClient.new(cred['login'], cred['secret']).get_data
  write_csv(:adaptv, data)
end

desc 'Collect fourninefive data'
task :fourninefive do
  if File.file?(get_yesterdays_file_path(:fourninefive))
    puts 'fourninefive data already scraped'
    next
  end
  puts 'working on fourninefive'
  require_relative 'lib/adforge_client'
  cred = YAML.load_file('secret.yml')['fourninefive']
  data = AdforgeClient.new(cred['login'], cred['secret']).get_data
  write_csv(:fourninefive, data)
end

def get_yesterdays_file_path(adnetwork)
  "tmp/#{Date.today.prev_day}/#{adnetwork}.csv"
end

def write_csv(adnet, data)
  Dir.mkdir "tmp/#{Date.today.prev_day}" unless Dir.exists? "tmp/#{Date.today.prev_day}"
  CSV.open(get_yesterdays_file_path(adnet), 'w') do |csv|
    data.each do |row|
      csv << row
    end
  end
end