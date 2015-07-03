class Rest::DeviceController < Rest::ServiceController

  include AuthValidation

  def list
    devicesSearch = DeviceMapping.joins(:device).select("devices.id", :device_name,:hw_id, :site_id, :enable, :created_at).where(site_id: getCurrentSite.id, user_id: getCurrentUser.id, customer_id: getCurrentCustomer.id)
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
    customer = params[:customer]
    hash.each { |d| self.registerDevice(d.name, d.hw_id, token, customer, site) }
  end

  def editDevices
    hash = params[:devices]
    hash.each { |d| self.editDevice(d.id, d.name) }
  end

  #deviceSelect equals device name. From Autocomplete
  def create
      return if !checkRequiredParams(:deviceSelect, :hw_id);
    self.registerDevice(params[:deviceSelect], params[:hw_id], params[:token], params[:customer_id], params[:site])
  end

  def update
    return if !checkRequiredParams(:device_id, :name);
    self.editDevice(params[:device_id], params[:name])
  end

  def delete
    return if !checkRequiredParams(:device_id);

    device = DeviceMapping.find(params[:device_id])
    if(device.nil?)
      error! :invalid_resource, :metadata => {:message => 'Device not found'}
    end

    device.delete

    expose 'done'
  end

  def suggestions
    return if !checkRequiredParams(:query);
    name = params[:query];
    search = DeviceMapping.joins(:device).select("devices.id as data , devices.name as value").where("lower(devices.name) like '%#{name.downcase}%'").where(site_id: getCurrentSite.id, user_id: getCurrentUser.id, customer_id: getCurrentCustomer.id)
    expose :suggestions => search
  end

  def suggestions_hw
    return if !checkRequiredParams(:query);
    name = params[:query];
    search = DeviceMapping.joins(:device).select("devices.hw_id as data , devices.name as value").where("lower(devices.name) like '%#{name.downcase}%'").where(site_id: getCurrentSite.id, user_id: getCurrentUser.id, customer_id: getCurrentCustomer.id)
    expose :suggestions => search
  end

  def addProperties
    return if !checkRequiredParams(:properties, :device, :token);
    properties = params[:properties]
    device = params[:device]

    ActiveRecord::Base.transaction do
      session = Session.find_by_token params[:token]

      if session.nil?
        expose :message=>'Session expired', :error=>true
        return;
      end

      searchDevice = Device.find_by(hw_id: device[:hw_id])

      if searchDevice.nil?
        searchDevice = Device.new
        searchDevice.name = device[:name]
        searchDevice.hw_id = device[:hw_id]
        searchDevice.save!
      else
        deviceMapping = DeviceMapping.find_by(device_id: searchDevice.id, user_id: session.user_id, site_id: session.site_id,customer_id: session.customer_id)
      end

      if deviceMapping.nil?

        #Name must be provided
        if device[:device_name].nil? && device[:name].nil?
          expose :message=>'Device name must be provided', :error=>true
          return;
        end

        deviceMapping = DeviceMapping.new
        deviceMapping.device = searchDevice
        deviceMapping.user_id = session.user_id
        deviceMapping.site_id = session.site_id
        deviceMapping.customer_id = session.customer_id
        deviceMapping.device_name = device[:device_name].nil? ? device[:name] : device[:device_name]
        deviceMapping.save!
      end

      if deviceMapping.nil?
        error! :not_acceptable, :metadata => {:message => 'Device Mapping no found'}
      end

      properties.each do |property|
        key = property[:key].downcase
        propertySearch = Property.find_by_key key

        #Is new?
        if(propertySearch.nil?)
          propertySearch = Property.new
          propertySearch.key = key
          propertySearch.metric = property[:metric]
          propertySearch.save!
        end

        deviceProperty = DeviceProperty.new
        deviceProperty.device_mapping = deviceMapping
        deviceProperty.property = propertySearch
        deviceProperty.dismiss_duration = property[:dismiss_duration]
        deviceProperty.dismiss_time = property[:dismiss_time].to_i if !property[:dismiss_time].nil?
        deviceProperty.created_at = property[:created_at].to_i if !property[:created_at].nil?
        deviceProperty.updated_at = property[:created_at].to_i if !property[:created_at].nil?
        deviceProperty.value = property[:value]
        deviceProperty.save!
      end

      expose 'done'
    end
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

  def change_status
    deviceUser = DeviceMapping.find_by(device_id: params[:id], user_id: getCurrentUser.id, site_id: getCurrentSite.id,customer_id: getCurrentCustomer.id)
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

  def average_report
    return if !checkRequiredParams(:device_id);

    propertiesAverage = DeviceProperty.joins(:property).joins(:device_mapping).where(device_mappings: {id: params[:device_id], site_id: getCurrentSite.id, customer_id: getCurrentCustomer.id, user_id: getCurrentUser.id}).select(:value, "count(device_properties.value) as count").group(:value)

    dataResponse = {}
    labels = Array.new
    propertyValues = Array.new

    propertiesAverage.each do |p|
      labels << p.value
      propertyValues << p.count.to_i
    end

    datasets = Array.new
    datasets << chart_data(propertyValues)
    dataResponse["datasets"] = datasets
    dataResponse["labels"] = labels
    expose dataResponse
  end

  def properties_report
    return if !checkRequiredParams(:device_id, :property_id);

    propertiesDevice = DeviceProperty.joins(:property).joins(:device_mapping).where(device_mappings: {id: params[:device_id], site_id: getCurrentSite.id, customer_id: getCurrentCustomer.id, user_id: getCurrentUser.id}, property_id: params[:property_id]).order("device_properties.created_at ASC").select(:property_id, :value, :key, "device_properties.created_at as created_at")

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

  def chart_data(propertyValues, label = nil)
    propertyData = {}
    primaryColor = Random.rand(0...220).to_s
    secondaryColor = Random.rand(0...220).to_s
    propertyData["fillColor"] = "rgba(#{primaryColor},#{secondaryColor},220,0.2)"
    propertyData["strokeColor"] = "rgba(#{primaryColor},#{secondaryColor},0,1)"
    propertyData["pointColor"] = "rgba(#{primaryColor},#{secondaryColor},0,1)"
    propertyData["pointStrokeColor"] = "rgba(#{primaryColor},#{secondaryColor},0,1)"
    propertyData["highlightFill"] = "rgba(#{primaryColor},#{secondaryColor},0,1)"
    propertyData["highlightStroke"] = "rgba(#{primaryColor},#{secondaryColor},0,1)"
    propertyData["data"] = propertyValues

    if !label.nil?
      propertyData["label"] = "#{primaryColor}"
    end

    return propertyData
  end
end