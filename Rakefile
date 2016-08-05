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
    return
  end
  require_relative 'lib/tremor_client'
  cred = YAML.load_file('secret.yml')['tremor']
  data = TremorClient.new(cred['username'], cred['password']).get_data
  write_csv(:tremor, data)
end

desc 'collect brightroll data'
task :brightroll do
  puts 'brightroll'
end

desc 'Collect yellowhammer data'
task :yellowhammer do
  puts 'yellowhammer'
end

desc 'Collect aol data'
task :aol do
  puts 'aol'
end

desc 'Collect fourninefive data'
task :fourninefive do
  puts 'fourninefive'
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