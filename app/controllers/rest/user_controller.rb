class Rest::UserController < Rest::SecureController

  AuthValidation.public_access :user => [:new,:confirmDone,:resetPassword]
  AuthValidation.admin_access :user => [:list]

  # User creation
  def register (skipValidation = false)
    return if !checkRequiredParams(:email,:password,:confirm_password,:firstname);
    newUser = User.new
    newUser.email = params[:email]
    newUser.password = params[:password]
    newUser.password_confirmation = params[:confirm_password]
    newUser.firstname = params[:firstname]
    newUser.lastname = params[:lastname]
    newUser.phone = params[:phone] if (!params[:phone].nil?)
    newUser.role_id = params[:role_id] unless params[:role_id].nil?
    newUser.site_id = params[:site_id] unless params[:site_id].nil?
    newUser.skip_confirmation! if skipValidation
    newUser.save
    expose 'done'
  end


  def create
    self.register(true)
  end

  # User update
  def update

    return if !checkRequiredParams(:user_id,:email,:firstname);

    tmpUser = User.find(params[:user_id]);
    if(tmpUser.nil?)
      error! :invalid_resource, :metadata => {:message => 'User not found'}
    end

    tmpUser.email = params[:email] if (!params[:email].nil?)
    tmpUser.firstname = params[:firstname] if (!params[:firstname].nil?)
    tmpUser.lastname = params[:lastname] if (!params[:lastname].nil?)
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
      usersSearch = User.where("lower(firstname) like '%#{value}%' OR lower(lastname) like '%#{value}%' OR lower(email) like '%#{value}%'");
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
end