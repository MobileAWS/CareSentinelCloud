class Rest::SiteConfigController < Rest::SecureController

   include AuthValidation

   require 'rufus-scheduler'
   require 'csv'

   SCHEDULER = Rufus::Scheduler.new

   def self.init
     # devices = DeviceProperty.all
     # devices.each do |d|
     #    properties = d.properties.select(:device_id, :property_id, :value, :name, :site_id, :created_at, :updated_at, :key, :metric)
     #   d.each
     # end

     #For migration
     if ActiveRecord::Base.connection.table_exists? 'site_configs'
       siteConfig = SiteConfig.where(name: 'purge_days')
       ##For seed
       if !siteConfig.nil?
         if siteConfig.respond_to?('each')
           siteConfig.each do |c|
             self.schedule_site_purge(c)
           end
         else
             self.schedule_site_purge(siteConfig)
         end
       end
     end
   end

   def purge_days
     return if !checkRequiredParams(:purge_days);

     siteConfig = SiteConfig.find_by(name: 'purge_days', site_id: getCurrentSite.id)

     if !siteConfig.nil?
       siteConfig.value = params[:purge_days]
       siteConfig.save!
     end

     #Kill older job
     if !SCHEDULER.job(siteConfig.job_id).nil?
       SCHEDULER.unschedule(siteConfig.job_id)
     end

     Rest::SiteConfigController.schedule_site_purge(siteConfig)

     expose 'done'
   end

  def self.schedule_site_purge(siteConfig)
    now = Time.new
    last_update = siteConfig.updated_at
    days = (siteConfig.value.to_i - (now - last_update).to_i / (24 * 60 * 60)).to_s + 'd'

    job_id = SCHEDULER.every days do
      siteConfig = SiteConfig.find_by_job_id job_id

      if !siteConfig.nil?
        self.purge(siteConfig)
      end
    end

    if !job_id.nil?
      siteConfig.update_column(:job_id, job_id)
    end

  end

  def self.purge(siteConfig)
    properties = DeviceProperty.properties.select(:device_id, :property_id, :value, :name, :site_id, :created_at, :updated_at, :key, :metric)
    properties.each do |p|
      puts p
    end
  end

end