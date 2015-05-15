class Rest::DeviceController < Rest::ServiceController

  include AuthValidation

  def list
    devicesSearch = getCurrentUser.devices.select(:id, :name, :site_id, :enable).where(site_id: getCurrentSite.id)
    if !params[:search].nil? && !devicesSearch.nil?
      value = params[:search][:value].nil? ? '' :  params[:search][:value]
      value = value.downcase
      devicesSearch = devicesSearch.where("lower(name) like '%#{value}%'");
    end

    if !devicesSearch.nil?
      expose paginateObject(devicesSearch)
    else
      expose ''
    end
  end

  def createDevices
    hash = params[:devices]
    token = params[:token]
    site = params[:site]
    hash.each { |d| self.registerDevice(d.name, token, site) }
  end

  def editDevices
    hash = params[:devices]
    hash.each { |d| self.editDevice(d.id, d.name) }
  end

  def create
    return if !checkRequiredParams(:deviceSelect);
    self.registerDevice(params[:deviceSelect], params[:token], params[:site])
  end

  def update
    return if !checkRequiredParams(:device_id, :name);
    self.editDevice(params[:device_id], params[:name])
  end

  def delete
    return if !checkRequiredParams(:device_id);

    temp = Device.find(params[:device_id])
    if(temp.nil?)
      error! :invalid_resource, :metadata => {:message => 'Device not found'}
    end

    temp.delete
    expose 'done'
  end

  def suggestions
    return if !checkRequiredParams(:query);
    name = params[:query];
    search = Device.select('id as data','name as value').where("lower(devices.name) like '%#{name.downcase}%' AND devices.site_id = #{getCurrentSite.id}");
    expose :suggestions => search
  end

  def addProperties
    properties = params[:properties]
    device = params[:device]

    properties.each do |property|
      key = property[:key].downcase
      propertySearch = Property.find_by_key key

      if(propertySearch.nil?)
        propertySearch = Property.new
        propertySearch.key = key
        propertySearch.metric = property[:metric]
      end

      device = Device.find device[:id]

      propertyDevice = propertySearch.device_properties.find_by(property_id: propertySearch.id,device_id: device.id)
      value = property[:value]

      if(propertyDevice.nil?)
        propertySearch.save! && propertySearch.device_properties.create(device: device, value: value)
      else
        propertySearch.save! && propertyDevice.update_attribute(:value, value)
      end

    end

    expose 'done'
  end

  def registerDevice(name, token, site)
    newDevice = Device.new

    site = Site.find site
    userSession = Session.find_by_token token
    newDevice.user << userSession.user

    newDevice.name = name
    newDevice.site = site
    newDevice.save!
    expose 'done'
  end

  def editDevice(id, name)
    temp = Device.find(id)
    if(temp.nil?)
      error! :invalid_resource, :metadata => {:message => 'Device not found'}
    end
    temp.name = name
    temp.save!
    expose 'done'
  end

end