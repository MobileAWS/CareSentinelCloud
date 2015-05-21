class Rest::UserController < Rest::SecureController

  AuthValidation.public_access :user => [:register,:confirmDone,:resetPassword]
  AuthValidation.admin_access :user => [:list, :create, :update, :addSite, :removeSite]
  AuthValidation.token_action :user => [:generateUserId]
  # User creation
  def register (skipValidation = false)
    return if !checkRequiredParams(:email,:password,:confirm_password,:sitesUser,:customer_id);
    newUser = User.new
    newUser.email = params[:email]
    newUser.password = params[:password]
    newUser.password_confirmation = params[:confirm_password]
    newUser.phone = params[:phone] if (!params[:phone].nil?)
    newUser.role_id = params[:role_id] unless params[:role_id].nil?
    newUser.customer_id = params[:customer_id]

    newUser.skip_confirmation! if skipValidation
    newUser.save

    siteIds = params[:sitesUser].split(",")
    siteIds.each do |id|
      site = Site.find id
      siteUser = SiteUser.new
      siteUser.site = site
      siteUser.user = newUser
      siteUser.save
    end
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
    tmpUser.customer_id = params[:customer_id] if (!params[:customer_id].nil?)
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
      usersSearch = User.where("customer_id = #{value.empty? ? -1 : value} OR lower(email) like '%#{value}%'");
    end
    usersSearch = User.all if usersSearch.nil?
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