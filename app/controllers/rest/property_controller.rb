class Rest::PropertyController < Rest::ServiceController

  include AuthValidation

  def list
    if getCurrentUser.isAdmin?
      propertiesList = Property.all.select("properties.id", "properties.key", "properties.metric", "'N/A' as value", :created_at, :dismiss_time)
    else
      propertiesList = params[:filter].nil? || params[:filter].empty? ?
          DeviceProperty.joins(:device_mapping, :property).joins(:device_mapping).where(device_mappings: {site_id: getCurrentSite.id, user_id: getCurrentUser.id, customer_id: getCurrentCustomer.id}).select("device_mappings.device_name", "properties.id", "initcap(properties.key) as key", "properties.metric", :value, :created_at, :dismiss_time) :
          DeviceProperty.joins(:device_mapping, :property).joins(:device_mapping).where(device_mappings: {id: params[:filter], site_id: getCurrentSite.id, user_id: getCurrentUser.id, customer_id: getCurrentCustomer.id}).select("device_mappings.device_name", "properties.id", "initcap(properties.key) as key", "properties.metric", :value, :created_at, :dismiss_time)
    end

    if !propertiesList.nil?
      propertiesList = propertiesList.order(:created_at => :desc)
      expose paginateObject(propertiesList)
    else
      expose ''
    end
  end

  def create
    user = getCurrentUser
    return if !user.isAdmin? && !checkRequiredParams(:property_name, :property_device_id, :metric, :value, :created_at);
    return if user.isAdmin? && !checkRequiredParams(:property_name, :metric, :created_at);

    ActiveRecord::Base.transaction do
      key = params[:property_name].downcase
      propertySearch = Property.find_by_key key

      if (propertySearch.nil?)
        propertySearch = Property.new
        propertySearch.key = key
        propertySearch.metric = params[:metric]
        propertySearch.save!
      end

      if !user.isAdmin?
        #Must exists
        deviceMapping = DeviceMapping.find params[:property_device_id]

        if deviceMapping.nil?
          error! :not_acceptable, :metadata => {:message => 'Device Mapping not found'}
        end

        deviceProperty = DeviceProperty.new
        deviceProperty.device_mapping = deviceMapping
        deviceProperty.property = propertySearch
        deviceProperty.value = params[:value]
        deviceProperty.created_at = Date.strptime(params[:created_at], '%m/%d/%Y %I:%M %p')
        deviceProperty.dismiss_time = Date.strptime(params[:dismiss_time], '%m/%d/%Y %I:%M %p')
        deviceProperty.save!
      end

      expose 'done'
    end
  end

end