# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adops_report_scrapper/version'

Gem::Specification.new do |spec|
  spec.name          = "adops_report_scrapper"
  spec.version       = AdopsReportScrapper::VERSION
  spec.authors       = ["Stayman Hou"]
  spec.email         = ["stayman.hou@gmail.com"]

  spec.summary       = %q{Adops Report Scrapper is a collection of web scrappers that can automatically extract the data from your ad partners.}
  spec.description   = %q{Adops Report Scrapper is a collection of web scrappers that can automatically extract the data from your ad server, ad networks, ad exchanges, and other ad partners. It is an open source alternative to [STAQ](http://www.staq.com/). Say good-bye to spreadsheet. At the moment, this gem only focus on getting the data in. It is up to you how you would aggregate the data into your pageview & dfp/ad server data set.}
  spec.homepage      = 'https://github.com/StaymanHou/adops_report_scrapper'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
