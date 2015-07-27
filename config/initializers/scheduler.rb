
require 'rufus-scheduler'
require 'csv'
require 'libs/scheduler'

SCHEDULER = Rufus::Scheduler.new

#For migration
if ActiveRecord::Base.connection.table_exists? 'site_configs'
  siteConfig = SiteConfig.where(name: 'purge_days')
  ##For seed
  if !siteConfig.nil?
    if siteConfig.respond_to?('each')
      siteConfig.each do |c|
        Scheduler::schedule_site_purge c
      end
    else
      Scheduler::schedule_site_purge(siteConfig)
    end
  end
end