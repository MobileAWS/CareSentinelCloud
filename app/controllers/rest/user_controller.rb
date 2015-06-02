class Rest::UserController < Rest::SecureController

  AuthValidation.public_access :user => [:register,:confirmDone,:resetPassword, :list, :removeCustomerId, :addCustomerId, :create, :update, :addSite, :removeSite, :delete]
  AuthValidation.token_action :user => [:generateUserId]
  # User creation
  def register (skipValidation = true)
    return if !checkRequiredParams(:email,:password,:confirm_password,:sitesUser, :customersUser);

    if params[:sitesUser].empty?
      expose :message=>'Site must be provided', :error=>true
      return
    end

    if params[:customersUser].empty?
      expose :message=>'Customer ID must be provided', :error=>true
      return
    end

    newUser = User.new
    newUser.email = params[:email]
    newUser.password = params[:password]
    newUser.password_confirmation = params[:confirm_password]
    newUser.phone = params[:phone] if (!params[:phone].nil?)
    newUser.role_id = params[:role_id] unless params[:role_id].nil?

    siteIds = params[:sitesUser].split(",")
    siteIds.each do |id|
      site = Site.find id
      newUser.sites << site
    end

    customersIDs = params[:customersUser].split(",")
    customersIDs.each do |id|
      customerSearch = Customer.find_by(id: id)
      if customerSearch.nil?
        customerSearch = Customer.new
        customerSearch.customer_id = id
        customerSearch.save!
      end

      newUser.customers << customerSearch
    end

    newUser.skip_confirmation! if skipValidation
    newUser.save

    expose 'done'
  end

  def create
    self.register(true)
  end

  # User update
  def update
    return if !checkRequiredParams(:user_id);

    tmpUser = User.find(params[:user_id]);
    if(tmpUser.nil?)
      error! :invalid_resource, :metadata => {:message => 'User not found'}
    end

    tmpUser.email = params[:email] if (!params[:email].nil?)
    tmpUser.phone = params[:phone] if (!params[:phone].nil?)
    tmpUser.role_id = params[:role_id] unless params[:role_id].nil?
    tmpUser.save!

    expose 'done'
  end

  def confirmDone
  end

  def list
    usersSearch = nil
    if !params[:search].nil?
      value = params[:search][:value].nil? ? '' :  params[:search][:value]
      value = value.downcase

      if getCurrentUser.isAdmin?
        usersSearch = User.joins(:role).where("lower(email) like '%#{value}%'").select(:id, :email, :phone, "roles.name as role_name");
      else
        usersSearch = User.joins(:role).joins(:customers).where(customer_users: {customer_id: getCurrentCustomer.id}).where("lower(email) like '%#{value}%' AND roles.role_id = 'caregiver'").select(:id, :email, :phone, "roles.name as role_name");
      end

    end
    usersSearch = User.all.select(:email, :phone, "roles.name as role_name") if usersSearch.nil?
    expose paginateObject(usersSearch)
  end

  def delete
    return if !checkRequiredParams(:user_id);

    tmpUser = User.find(params[:user_id])
    if tmpUser.nil?
      error! :invalid_resource, :metadata => {:message => 'User not found'}
    end
    tmpUser.delete
    expose 'done'
  end

  def profile
    user = nil
    if params[:user_id].nil? then
      user = getCurrentUser
    else
      user = User.find(params[:user_type].to_i)
    end

    if user.nil? then
      error! :invalid_resource, :metadata => {:message => 'User not found'}
      return;
    end

    expose :user => user
  end

  def resetPassword
    return unless checkRequiredParams :email
    user = User.where('lower(email) = :email',{email: params[:email].downcase}).first
    if !user.nil?
      user.send_reset_password_instructions
    end
    expose 'Done'
  end

  def generateUserId
    value = ActiveRecord::Base.connection.execute(%Q{ SELECT nextval('customers_ids_sequence'); });
    expose :customer_id => value
  end

  def addCustomerId
    return if !checkRequiredParams(:customer_number, :user_id);

    user = User.find(params[:user_id])
    customerUserSearch = user.customers.find_by(customer_id: params[:customer_number])
    if customerUserSearch.nil?
      customer = Customer.find_by_customer_id params[:customer_number]
      if customer.nil?
        customer = Customer.new
        customer.customer_id = params[:customer_number]
        customer.save!
      end

      customerUser = CustomerUser.new
      customerUser.customer = customer
      customerUser.user = user
      customerUser.save!

      expose 'done'
    else
      expose 'The customer id is already associated for this user'
    end
  end

  def removeCustomerId
    return if !checkRequiredParams(:customer_id, :user_id);
    #The user must have one customer id
    customers = CustomerUser.where(user_id: params[:user_id]).count

    if customers > 1
      customerSearch = CustomerUser.find_by(user_id: params[:user_id], customer_id: params[:customer_id])
      if !customerSearch.nil?
        customerSearch.destroy
      end
      expose 'done'
    else
      expose 'User must have one customer ID'
    end
  end

  def addSite
    return if !checkRequiredParams(:site_id, :user_id);

    user = User.find(params[:user_id])
    siteSearch = user.sites.find_by(id: params[:site_id])
    if siteSearch.nil?
      siteUser = SiteUser.new
      siteUser.user = user
      siteUser.site = Site.find params[:site_id]
      siteUser.save!
      expose 'done'
    else
      expose 'The site is already associated for this user'
    end
  end

  def removeSite
    return if !checkRequiredParams(:site_id, :user_id);
    #The user must have one site
    sites = SiteUser.where(user_id: params[:user_id]).count

    if sites > 1
      siteSearch = SiteUser.find_by(site_id: params[:site_id], user_id: params[:user_id])
      if !siteSearch.nil?
        siteSearch.destroy
      end
      expose 'done'
    else
      expose 'User must have one site'
    end
  end
end