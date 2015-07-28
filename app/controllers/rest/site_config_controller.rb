class Rest::SiteConfigController < Rest::SecureController

   include AuthValidation

   require 'libs/scheduler'

   def purge_days
     return if !checkRequiredParams(:purge_days, :purge_enable);

     siteConfig = SiteConfig.find_by(name: 'purge_days')

     if !siteConfig.nil?
       siteConfig.enabled = params[:purge_enable]
       siteConfig.value = params[:purge_days]
       siteConfig.save!
     end

     #Kill older job
     Scheduler::update_job(siteConfig.job_id)

     if params[:purge_enable] == 'true'
       Scheduler::schedule_site_purge(siteConfig)
     end

     expose 'done'
   end

   def emails_purge
     return if !checkRequiredParams(:emails);

     siteConfig = SiteConfig.find_by(name: 'emails_purge')

     if siteConfig.nil?
       siteConfig = SiteConfig.new
       siteConfig.name = 'emails_purge'
     end

     siteConfig.value = params[:emails]
     siteConfig.enabled = true
     siteConfig.save!

     expose 'done'
   end



end