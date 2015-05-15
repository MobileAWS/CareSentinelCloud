class CaregiverController < ApplicationController

  def device_properties
    device = Device.find params[:id]
    @properties = device.device_properties.all

    render "caregiver/device_properties", :layout => false
  end

end
