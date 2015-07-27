
class Scheduler

  require 'rufus-scheduler'
  require 'csv'

  SCHEDULER = Rufus::Scheduler.new


  def self.update_job(job_id)
    if !SCHEDULER.job(job_id).nil?
      SCHEDULER.unschedule(job_id)
    end
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
    CSV.open("/purge_"+Time.new.strftime("%Y%m%d")+".csv", "wb") do |csv|
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