
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
    numberDays = siteConfig.value.to_i - (now - last_update).to_i / (24 * 60 * 60)
    days = '60s'
    # days = (numberDays).to_s + 'd'

    if numberDays <= 0
      self.purge(siteConfig)

      days = siteConfig.value + 'd'
    end

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
    csvName = "cleanup_data.csv"
    CSV.open(csvName, "w") do |csv|
      csv << ['Device', 'Sensor', 'Status', 'Alerted At', 'Acknowledged At']
      date = Date.today - siteConfig.value.to_i
      properties = DeviceProperty.joins(:device_mapping).joins(:property)
      # properties = DeviceProperty.joins(:device_mapping).joins(:property).where("properties.created_at < '#{date}'")
      properties.each do |p|
        csv << [p.device_mapping.device.name, p.property.key.camelize, p.value.camelize, p.created_at, p.dismiss_time]
        # p.delete
      end

    end

    MainMailer.send_csv(csvName).deliver

    siteConfig.updated_at = Time.new
    siteConfig.save!
  end

end