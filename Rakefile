require 'bundler/gem_tasks'
require 'yaml'
require 'csv'
require 'date'
require 'adops_report_scrapper'

require 'byebug'

desc 'Collect all data'
task :all => [:openx, :tremor, :brightroll, :yellowhammer, :adaptv, :fourninefive, :adx, :revcontent, :gcs, :browsi, :netseer, :sonobi, :nativo, :adsupply, :marfeel, :adsense, :criteo, :triplelift, :conversant, :liveintent, :adiply, :contentad, :facebookaudience] do # openx is the most unstable one, run it first
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

desc 'Collect nativo data'
task :nativo do
  save_as_csv :nativo, :nativo
end

desc 'Collect adsupply data'
task :adsupply do
  save_as_csv :adsupply, :adsupply
end

desc 'Collect marfeel data'
task :marfeel do
  save_as_csv :marfeel, :marfeel
end

desc 'Collect adsense data'
task :adsense do
  save_as_csv :adsense, :adsense
end

desc 'Collect criteo data'
task :criteo do
  save_as_csv :criteo, :criteo
end

desc 'Collect triplelift data'
task :triplelift do
  save_as_csv :triplelift, :triplelift
end

desc 'Collect conversant data'
task :conversant do
  save_as_csv :conversant, :conversant
end

desc 'Collect liveintent data'
task :liveintent do
  save_as_csv :liveintent, :liveintent
end

desc 'Collect adiply data'
task :adiply do
  save_as_csv :adiply, :adiply
end

desc 'Collect contentad data'
task :contentad do
  save_as_csv :contentad, :contentad
end

desc 'Collect facebookaudience data'
task :facebookaudience do
  save_as_csv :facebookaudience, :facebookaudience
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
  cred = YAML.load_file('secret.yml')[adnet.to_s]
  data = AdopsReportScrapper.get_scrapper(adnet, cred['login'], cred['secret'], cred['options']).get_data
  byebug
  write_csv(adnet, data)
end