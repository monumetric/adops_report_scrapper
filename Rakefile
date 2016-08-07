require 'bundler/gem_tasks'
require 'yaml'
require 'csv'
require 'date'

require 'byebug'

desc 'Collect all data'
task :all => [:tremor, :brightroll, :yellowhammer, :adaptv, :fourninefive, :adx, :revcontent, :gcs, :browsi, :netseer, :sonobi, :openx] do # openx is the most unstable one, last to run
  puts '========== You are all set'
end

desc 'Collect tremor data'
task :tremor do
  save_as_csv :tremor, :tremor
end

desc 'collect brightroll data'
task :brightroll do
  save_as_csv :brightroll, :brightroll
end

desc 'Collect yellowhammer data'
task :yellowhammer do
  save_as_csv :yellowhammer, :springserve
end

desc 'Collect adaptv data'
task :adaptv do
  save_as_csv :adaptv, :adaptv
end

desc 'Collect fourninefive data'
task :fourninefive do
  save_as_csv :fourninefive, :adforge
end

desc 'Collect adx data'
task :adx do
  save_as_csv :adx, :adx
end

desc 'Collect revcontent data'
task :revcontent do
  save_as_csv :revcontent, :revcontent
end

desc 'Collect gcs data'
task :gcs do
  save_as_csv :gcs, :gcs
end

desc 'Collect browsi data'
task :browsi do
  save_as_csv :browsi, :browsi
end

desc 'Collect openx data'
task :openx do
  save_as_csv :openx, :openx
end

desc 'Collect netseer data'
task :netseer do
  save_as_csv :netseer, :netseer
end

desc 'Collect sonobi data'
task :sonobi do
  save_as_csv :sonobi, :sonobi
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

def save_as_csv(adnet, scrapper) # adnet and scrapper are both sym
  if File.file?(get_yesterdays_file_path(adnet))
    puts "========== #{adnet} data already scraped"
    return
  end
  puts "========== working on #{adnet}"
  require_relative "lib/#{scrapper}_client"
  cred = YAML.load_file('secret.yml')[adnet.to_s]
  scrapper_client_klass = Object.const_get "#{scrapper.capitalize}Client"
  data = scrapper_client_klass.new(cred['login'], cred['secret'], cred['options']).get_data
  write_csv(adnet, data)
end