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

  def properties_suggestions
    return if !checkRequiredParams(:query);
    name = params[:query];
    search = getCurrentUser.devices.joins(:device_properties).joins(:properties).where("(lower(devices.name) like '%#{name.downcase}%' OR lower(properties.key) like '%#{name.downcase}%') AND devices.site_id = #{getCurrentSite.id} ").select("DISTINCT(devices.id||','||properties.id) as data","devices.name||' - '||properties.key as value")
    expose :suggestions => search
  end

  def addProperties
    properties = params[:properties]
    device = params[:device]

    properties.each do |property|
      key = property[:key].downcase
      propertySearch = Property.find_by_key key

      #Is new?
      if(propertySearch.nil?)
        propertySearch = Property.new
        propertySearch.key = key
        propertySearch.metric = property[:metric]
      end

      device = Device.find device[:id]

      propertyDevice = propertySearch.device_properties.find_by(property_id: propertySearch.id,device_id: device.id)
      value = property[:value]

      propertySearch.save! && propertySearch.device_properties.create(device: device, value: value)

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

  def change_status
    deviceUser = DeviceUser.find_by(user_id: getCurrentUser.id, device_id: params[:id])
    status = deviceUser.enable
    deviceUser.enable = !status
    deviceUser.save!
    expose 'done'
  end

  def properties
    return if !checkRequiredParams(:id);

    propertiesDevice = DeviceProperty.joins(:property).where(device_id: params[:id]).order("device_properties.property_id ASC").order("device_properties.created_at ASC").select(:property_id, :value, :key)

    expose propertiesDevice
  end

  def properties_report
    return if !checkRequiredParams(:device_id, :property_id);

    propertiesDevice = DeviceProperty.joins(:property).where(device_id: params[:device_id], property_id: params[:property_id]).order("device_properties.created_at ASC").select(:property_id, :value, :key, "device_properties.created_at as created_at")

    dataResponse = {}
    labels = Array.new
    propertyValues = Array.new
    datasets = Array.new

    propertiesDevice.each_with_index do |p, index|
      label = p.created_at.strftime("%Y-%m-%d")

      propertyValues << p.value
      labels << label

      if propertiesDevice.size - 1 == index && !propertyValues.empty?
        datasets << chart_data(propertyValues, p.key)
      end
    end

    dataResponse["datasets"] = datasets
    dataResponse["labels"] = labels
    expose dataResponse
  end

  def properties_report_old
    return if !checkRequiredParams(:id);

    propertiesDevice = DeviceProperty.joins(:property).where(device_id: params[:id]).order("device_properties.property_id ASC").order("device_properties.created_at ASC").select(:property_id, :value, :key, "device_properties.created_at as created_at")

    id = -1
    dataResponse = {}
    labels = Array.new
    propertyValues = Array.new
    datasets = Array.new

    propertiesDevice.each_with_index do |p, index|
      id = id == -1 ? p.property_id : id
      label = p.created_at.strftime("%Y-%m-%d")
      if p.property_id == id
        propertyValues << p.value
        # if !labels.include?(label)
          labels << label
        # end
      else
        if !propertyValues.empty?
          datasets << chart_data(propertyValues, p.key)
        end

        id = p.property_id
        propertyValues = Array.new
        propertyValues << p.value
        # if !labels.include?(label)
          labels << label
        # end
      end

      if propertiesDevice.size - 1 == index && !propertyValues.empty?
        datasets << chart_data(propertyValues, p.key)
      end
    end

    dataResponse["datasets"] = datasets
    dataResponse["labels"] = labels.sort
    expose dataResponse
  end

  def chart_data(propertyValues, label)
    propertyData = {}
    primaryColor = Random.rand(0...220).to_s
    propertyData["fillColor"] = "rgba(#{primaryColor},220,220,0.2)"
    propertyData["strokeColor"] = "rgba(#{primaryColor},0,0,1)"
    propertyData["pointColor"] = "rgba(#{primaryColor},0,0,1)"
    propertyData["pointStrokeColor"] = "rgba(#{primaryColor},0,0,1)"
    propertyData["pointHighlightFill"] = "rgba(#{primaryColor},0,0,1)"
    propertyData["pointHighlightStroke"] = "rgba(#{primaryColor},0,0,1)"
    propertyData["data"] = propertyValues
    propertyData["label"] = label
    return propertyData
  end

end