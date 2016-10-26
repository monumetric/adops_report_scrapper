require "adops_report_scrapper/version"

module AdopsReportScrapper
  def self.get_scrapper(module_name, login, secret, options = nil)
    scrapper_client_klass = self.const_get "#{self.camelcase(module_name)}Client"
    scrapper_client_klass.new(login, secret, options)
  end

  private

  def self.camelcase(str)
    str.to_s.downcase.split('_').map { |word| word.capitalize }.join
  end
end

require 'adops_report_scrapper/adaptv_client'
# require 'adops_report_scrapper/adforge_client'
require 'adops_report_scrapper/adiply_client'
require 'adops_report_scrapper/adsense_client'
require 'adops_report_scrapper/adsupply_client'
require 'adops_report_scrapper/adx_client'
require 'adops_report_scrapper/brightroll_client'
require 'adops_report_scrapper/browsi_client'
require 'adops_report_scrapper/contentad_client'
require 'adops_report_scrapper/conversant_client'
require 'adops_report_scrapper/criteo_client'
require 'adops_report_scrapper/facebookaudience_client'
require 'adops_report_scrapper/gcs_client'
require 'adops_report_scrapper/liveintent_client'
require 'adops_report_scrapper/marfeel_client'
require 'adops_report_scrapper/nativo_client'
require 'adops_report_scrapper/netseer_client'
require 'adops_report_scrapper/openx_client'
require 'adops_report_scrapper/revcontent_client'
require 'adops_report_scrapper/sonobi_client'
require 'adops_report_scrapper/springserve_client'
require 'adops_report_scrapper/tremor_client'
require 'adops_report_scrapper/triplelift_client'
require 'adops_report_scrapper/adtechus_client'
require 'adops_report_scrapper/zedo_client'
require 'adops_report_scrapper/adtomation_client'
require 'adops_report_scrapper/rhythmone_client'
require 'adops_report_scrapper/littlethings_client'
