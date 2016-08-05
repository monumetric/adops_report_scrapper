require 'bundler/gem_tasks'
require 'yaml'
require 'byebug'

desc 'Collect all data'
task :all => [:tremor, :brightroll, :yellowhammer, :aol, :fourninefive] do
  puts 'all'
end

desc 'Collect tremor data'
task :tremor do
  require_relative 'lib/tremor_client'
  cred = YAML.load_file('secret.yml')['tremor']
  TremorClient.new(cred['username'], cred['password']).get_data
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
