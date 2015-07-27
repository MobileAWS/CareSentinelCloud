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





end