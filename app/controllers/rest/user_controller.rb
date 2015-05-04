class Rest::UserController < Rest::SecureController

  AuthValidation.public_access :user => [:register,:confirmDone,:resetPassword]
  AuthValidation.admin_access :user => [:list]
  AuthValidation.token_action :user => [:generateUserId]
  # User creation
  def register (skipValidation = false)
    return if !checkRequiredParams(:email,:password,:confirm_password,:customer_site_id,:customer_id);
    newUser = User.new
    newUser.email = params[:email]
    newUser.password = params[:password]
    newUser.password_confirmation = params[:confirm_password]
    newUser.phone = params[:phone] if (!params[:phone].nil?)
    newUser.role_id = params[:role_id] unless params[:role_id].nil?
    newUser.customer_id = params[:customer_id]

    # Find user site, by id, if it exists
    site = Site.find_by_name params[:customer_site_id];
    if !site then
      site = Site.new
      site.name = params[:customer_site_id]
      site.save!
    end

    newUser.site_id = site.id
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
    tmpUser.customer_id = params[:customer_id] if (!params[:customer_id].nil?)
    tmpUser.phone = params[:phone] if (!params[:phone].nil?)
    tmpUser.role_id = params[:role_id] unless params[:role_id].nil?
    tmpUser.site_id = params[:site_id] unless params[:site_id].nil?
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
      usersSearch = User.where("customer_id = #{value.empty? ? -1 : value} OR site_id = #{value.empty? ? -1 : value} OR lower(email) like '%#{value}%'");
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
    if user.nil?
      error! :bad_request, :metadata => {:message => 'User not found'}
      return
    end
    user.send_reset_password_instructions
    expose 'Done'
  end

  def generateUserId
    value = ActiveRecord::Base.connection.execute(%Q{ SELECT nextval('customers_ids_sequence'); });
    expose :customer_id => value
  end
end