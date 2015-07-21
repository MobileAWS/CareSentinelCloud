class Rest::DeviceMappingController < Rest::ServiceController

  include AuthValidation

  def list
    devicesSearch = DeviceMapping.joins(:device).where(site_id: getCurrentSite.id, user_id: getCurrentUser.id, customer_id: getCurrentCustomer.id).select(:id, :device_name,"devices.hw_id", :site_id, :enable, :created_at, "false as report")
    if !params[:search].nil? && !devicesSearch.nil?
      value = params[:search][:value].nil? ? '' :  params[:search][:value]
      value = value.downcase
      devicesSearch = devicesSearch.where("lower(device_name) like '%#{value}%'");
    end

    if !devicesSearch.nil?
      expose paginateObject(devicesSearch)
    else
      expose ''
    end
  end

  def create
    return if !checkRequiredParams(:deviceSelect, :hw_id);
    self.registerDevice(params[:deviceSelect], params[:hw_id], params[:token], params[:customer_id], params[:site])
  end

  def update
    return if !checkRequiredParams(:device_id, :name);
    self.editDevice(params[:device_id], params[:name])
  end

  def delete
    return if !checkRequiredParams(:devicemapping_id);

    device = DeviceMapping.find(params[:devicemapping_id])
    if(device.nil?)
      error! :invalid_resource, :metadata => {:message => 'Device not found'}
    end

    device.delete

    expose 'done'
  end

  def registerDevice(name, hw_id, token, customer_id, site_id)
    ActiveRecord::Base.transaction do
      session = Session.find_by_token token
      customer = Customer.find customer_id
      site = Site.find site_id

      #Check if device exists
      searchDevice = Device.find_by_hw_id hw_id

      if searchDevice.nil?
        searchDevice = Device.new
        searchDevice.name = name
        searchDevice.hw_id = hw_id
        searchDevice.save!
      else
        #Check if device mapping exists
        deviceMapping = DeviceMapping.find_by(device:searchDevice, site: site, customer: customer, user: session.user)

        if !deviceMapping.nil?
          expose :message=>'Device with this Hardware ID already exists', :error=>true
          return;
        end
      end


      deviceMapping = DeviceMapping.new
      deviceMapping.user = session.user
      deviceMapping.device = searchDevice
      deviceMapping.customer = customer
      deviceMapping.site = site
      deviceMapping.device_name = name
      deviceMapping.save!

      expose 'done'
    end
  end

  def editDevice(id, name)
    deviceMapping = DeviceMapping.find(id)
    if(deviceMapping.nil?)
      error! :invalid_resource, :metadata => {:message => 'Device not found'}
    end
    deviceMapping.device_name = name
    deviceMapping.save!

    expose 'done'
  end

  def suggestions
    return if !checkRequiredParams(:query);
    name = params[:query];
    search = DeviceMapping.select("id as data , device_name as value").where("lower(device_name) like '%#{name.downcase}%'").where(site_id: getCurrentSite.id, user_id: getCurrentUser.id, customer_id: getCurrentCustomer.id)
    expose :suggestions => search
  end

  def properties_suggestions
    return if !checkRequiredParams(:device_id);
    search = DeviceProperty.joins(:property).where(:device_mapping_id => params[:device_id]).select("distinct(properties.key)", :property_id)
    expose search
  end

end