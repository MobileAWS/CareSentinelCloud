class CaregiverController < ApplicationController

  require 'csv'
  include AuthValidation

  def device_properties
    device = Device.find params[:id]
    @properties = device.device_properties.all

    render "caregiver/device/device_properties", :layout => false
  end

  def download_devices
    @devices = getCurrentUser.devices.where(site_id: getCurrentSite.id)

    headers['Content-Disposition'] = "attachment; filename=\"device-list#{Time.now.strftime("_%d_%m_%Y%H%M")}.csv\""
    headers['Content-Type'] ||= 'text/csv'

    render "caregiver/device/download_devices", :layout => false
  end

end
