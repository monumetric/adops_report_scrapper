# Adops_Report_Scrapper

Adops Report Scrapper is a collection of web scrappers that can automatically extract the data from your ad server, ad networks, ad exchanges, and other ad partners. It is an open source alternative to [STAQ](http://www.staq.com/). Say good-bye to spreadsheet. At the moment, this gem only focus on getting the data in. It is up to you how you would aggregate the data into your pageview & dfp/ad server data set.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adops_report_scrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adops_report_scrapper

## Configure

`cp secret.sample.yml secret.yml`. And modify the credentials in the secret.yml accordingly.

## Usage

#### Example

```ruby
require 'adops_report_scrapper'
AdopsReportScrapper.get_scrapper(:brightroll, 'login', 'secret', {}).get_data

# return an array of arrays. First array is the header of the data table. Other arrays are the data
# example: [["Watch", "Status", "Name", "ID", "CPM Floor", "Revenue", "eCPM", "Requests", "Responses", "Response Rate", "Impressions", "Impression Rate", "Fill Rate", "Viewable Rate", "Clicks", "CTR", "Mid Rate", "Completion Rate", "Companion Impressions", "Companion Clicks", "Companion CTR", "Created On", "Last Modified"], ["", "", "My Post RON CDN", "3863603", "$6.00", "$9.99", "$6.68", "14,951", "2,556", "17.10%", "1,496", "58.53%", "10.01%", "60.87%", "7", "0.47%", "51.80%", "45.05%", "0.00%", "0", "0.00%", "03/23/2015", "06/25/2016"], ["", "", "My Post 400x300", "3855941", "$6.00", "$0.04", "$6.07", "78", "37", "47.44%", "6", "16.22%", "7.69%", "0.00%", "0", "0.00%", "50.00%", "66.67%", "0.00%", "0", "0.00%", "12/20/2013", "06/24/2016"], ["", "", "My Post", "3860218", "$7.00", "$0.03", "$8.07", "26", "12", "46.15%", "4", "33.33%", "15.38%", "0.00%", "0", "0.00%", "125.00%", "125.00%", "0.00%", "0", "0.00%", "10/10/2014", "06/09/2016"], ["", "", "My Post 640x480", "3855297", "$7.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "11/25/2013", "06/28/2016"], ["", "", "My Post 300x250", "3855943", "$2.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "12/20/2013", "06/09/2016"], ["", "", "Mobile - iPhone web…e My Post NCT", "3856072", "$4.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "01/07/2014", "05/23/2016"], ["", "", "Mobile - Android we…- The My Post", "3856089", "$4.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "01/08/2014", "05/23/2016"], ["", "", "Mobile - iPad web -…e My Post NCT", "3856127", "$4.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "01/10/2014", "05/23/2016"], ["", "", "My Today 6836382", "3860216", "$7.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "10/10/2014", "06/29/2016"], ["", "", "My Herald", "3860220", "$6.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "10/10/2014", "06/09/2016"], ["", "", "My News", "3860222", "$7.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "10/10/2014", "06/29/2016"], ["", "", "My Blog", "3860224", "$5.00", "$0.00", "$0.00", "15", "7", "46.67%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "10/10/2014", "06/09/2016"], ["", "", "My Times 400x300", "3863146", "$7.00", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "03/02/2015", "06/29/2016"], ["", "", "My Post RON UK", "3863604", "$5.46", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "03/23/2015", "06/09/2016"], ["", "", "My Post RON AU", "3863906", "$4.43", "$0.00", "$0.00", "0", "0", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0", "0.00%", "0.00%", "0.00%", "0.00%", "0", "0.00%", "04/01/2015", "06/09/2016"]]
```

## Supported Scrappers

Check `lib/adops_report_scrapper` directory for implemented scrappers.

Check `secret.sample.yml` for expected args to be passed to each scrapper.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/StaymanHou/adops_report_scrapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
