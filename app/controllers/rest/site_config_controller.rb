class Rest::SiteConfigController < Rest::SecureController

   include AuthValidation

   require 'rufus-scheduler'
   require 'csv'

   SCHEDULER = Rufus::Scheduler.new

   def self.init
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

     siteConfig = SiteConfig.find_by(name: 'purge_days')

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
    devices = DeviceProperty.all
    CSV.open("D:/purge_"+Time.new.strftime("%Y%m%d")+".csv", "wb") do |csv|
      csv << ["Device Name", "Site Id", "Property Name", "Metric", "Value"]
      devices.each do |d|
        device =  d.device
        date = Date.today - siteConfig.value.to_i
        properties = device.properties.where("properties.created_at < '#{date}'").select(:id, :device_id, :property_id, :created_at, :updated_at, :key, :metric, :value)
          properties.each do |p|
            csv << [device.name, device.site_id, p.key, p.metric, p.value]
            DeviceProperty.where(:property_id => p.id).destroy_all
            p.delete
          end
      end
    end

    siteConfig.updated_at = Time.new
    siteConfig.save!
  end

end