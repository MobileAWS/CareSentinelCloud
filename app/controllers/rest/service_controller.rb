class Rest::ServiceController < RocketPants::Base

  #around_action :set_timezone,:set_chronic_zone

  def set_timezone(&block)
    # Later we can use the timezone of the user
    Time.use_zone("US/Pacific",&block);
  end

  def set_chronic_zone
    Chronic.time_class = Time.zone
    yield
  end

  # Utility methods for all controllers
  def checkRequiredParams(*requiredParams)
    message = ''
    requiredParams.each do |paramSym|
      if params[paramSym].nil? then
        message += "No #{paramSym.to_s} specified.\\n"
      end
    end

    # Throw a bad request if not all parameters are in.
    if message.length > 0 then
      error! :bad_request, :metadata => {:message => message}
      return false;
    end

    return true;

  end

  def getDatTimeValue(value)
    return Time.zone.now unless !value.nil?
    return Time.zone.at (value.to_i) if value.is_a? Time
    Time.zone.at(Numeric(value)) rescue Chronic.parse(value);
  end

  def paginateObject(target)
    perPage = params[:per_page].nil? ? 10 : params[:per_page]
    page = params[:page].nil? ? 1 : params[:page]

    if !params[:order].nil?
      params[:order].each do |columnOrder|
        order = columnOrder[1]
        columnIndex = order[:column]
        columnData =  params[:columns][columnIndex]

        if !columnData.nil?
          orderQuery = "#{columnData[:data]} #{order[:dir].upcase}"
          target = target.order(orderQuery)
        end
      end
    end

    target.paginate(:page => page,:per_page => perPage)
  end

  def orderObject(target)


    return target
  end
end