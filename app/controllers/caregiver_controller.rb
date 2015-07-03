class CaregiverController < ApplicationController

  require 'csv'
  include AuthValidation

  def device_properties
    @properties = DeviceProperty.joins(:device_mapping).joins(:property).where("device_mappings.device_id=#{params[:id]}", "device_mappings.site_id= #{getCurrentSite.id}", "user_id= #{getCurrentUser.id}", "customer_id= #{getCurrentCustomer.id}")

    render "caregiver/device/device_properties", :layout => false
  end

  def download_devices
    @properties = DeviceProperty.joins(:device_mapping).joins(:property).where("device_mappings.site_id= #{getCurrentSite.id}", "user_id= #{getCurrentUser.id}", "customer_id= #{getCurrentCustomer.id}")

    headers['Content-Disposition'] = "attachment; filename=\"device-list#{Time.now.strftime("_%d_%m_%Y%H%M")}.csv\""
    headers['Content-Type'] ||= 'text/csv'

    render "caregiver/device/download_devices", :layout => false
  end

  def export_historic_report
    @properties = DeviceProperty.joins(:property).joins(:device_mapping).where(device_mappings: {id: params[:device_id], site_id: getCurrentSite.id, customer_id: getCurrentCustomer.id, user_id: getCurrentUser.id}, property_id: params[:property_id]).order("device_properties.created_at ASC")

    headers['Content-Disposition'] = "attachment; filename=\"historic_report#{Time.now.strftime("_%d_%m_%Y%H%M")}.csv\""
    headers['Content-Type'] ||= 'text/csv'

    render "caregiver/device/historic_report", :layout => false
  end

  def export_average_report
    @properties = DeviceProperty.joins(:property).joins(:device_mapping).where(device_mappings: {id: params[:device_id], site_id: getCurrentSite.id, customer_id: getCurrentCustomer.id, user_id: getCurrentUser.id}).select(:value, "count(device_properties.value) as count").group(:value)

    headers['Content-Disposition'] = "attachment; filename=\"average#{Time.now.strftime("_%d_%m_%Y%H%M")}.csv\""
    headers['Content-Type'] ||= 'text/csv'

    render "caregiver/device/average_report", :layout => false
  end

  def download_caregivers
    @users = User.joins(:sites).joins(:role).where(" roles.role_id = 'caregiver' ").select(:email, "sites.name as site_name", :customer_id, "roles.name as role_name")

    headers['Content-Disposition'] = "attachment; filename=\"user-list#{Time.now.strftime("_%d_%m_%Y%H%M")}.csv\""
    headers['Content-Type'] ||= 'text/csv'

    render "caregiveradmin/users/download_users", :layout => false
  end

end
