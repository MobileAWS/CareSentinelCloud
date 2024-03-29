class AuthenticationController < Rest::ServiceController

  include AuthValidation
  require 'securerandom'

  # Uses devise to log in the user into the system. This is the only place
  # where devise auth is actually used, the rest of the auth should be done with a valid
  # token. This action returns a token for the user. Devise, however, is used for other tasks,
  # like confirm user / recover a pwd

  def new
    user = User.not_deleted.find_for_database_authentication(:email => params[:email])
    if user.nil? then
      expose :message=>'User or password incorrect for this site', :error=>true
      return;
    end

    # Invalidate any session the user ha now
    # invalidateUserSession user

    # Validate the password, as you can see, if the password is wrong, the user seession is already
    # gone, this can improve security.
    if !user.valid_password?(params[:password]) then
      expose :message=>'User or password incorrect for this site', :error=>true
      return;
    end

    #Validate the customer id
    if !user.isAdmin? && !user.valid_customer_id(params[:customer_id]) then
      expose :message=>'User, password or customer id incorrect for this site', :error=>true
      return
    end

    #Validate the user site
    if user.isSiteLogin? && (params[:site_name].nil? || !user.valid_site?(params[:site_name])) then
      expose :message=>'User, password or customer id incorrect for this site', :error=>true
      return
    end

    if params[:user_type] then
      if user.user_type_name.downcase != params[:user_type].downcase
        expose :message=>"Only '#{params[:user_type].capitalize}' Users are available to use this app", :error => true
        return
      end
    end

    # Create a new session
    site = Site.find_site_by_name params[:site_name]
    customer = Customer.find_by_customer_id params[:customer_id]
    token = generateUserSession(user, site, customer)

    setCurrentUser user
    expose :token => token, :role => getCurrentRole.role_id
  end

  def create
    return if !checkRequiredParams(:email, :password, :site_name, :customer_id);

    user = User.includes(:customers,:sites).not_deleted.find_for_database_authentication(:email => params[:email])

    if user.nil? then
      expose :message=>'User or password incorrect for this site', :error=>true
      return;
    end

    customerSearch = Customer.find_by(customer_id: params[:customer_id])

    save_user = false;

    if customerSearch.nil?
      customerSearch = Customer.new
      customerSearch.customer_id = params[:customer_id]
      customerSearch.save!
      user.customers << customerSearch
      save_user = true;
    else
      idx = user.customers.index{|customer|  customer.id == customerSearch.id}
      if idx.nil?
        user.customers << customerSearch if idx.nil?
        save_user = true
      end
    end

    siteSearch = Site.find_site_by_name params[:site_name]

    if siteSearch.nil?
      siteSearch = Site.new
      siteSearch.name = params[:site_name].upcase
      siteSearch.save!
      user.sites << siteSearch
      save_user = true
    else
      idx = user.sites.index{|site|  site.id == siteSearch.id}
      if idx.nil?
        user.sites << siteSearch
        save_user = true
      end
    end

    # Save changes on the user once.
    user.save! if save_user

    self.new

  end

  def logout
    if params[:token].nil? then
      expose :message=>"No session specified", :error=>true
      return;
    end


    userSession = Session.find_by_token(params[:token])

    if !userSession.nil? then
      invalidateUserSession userSession.user
    end
    expose :message=>'Done'
  end

  def sites
    sites = Site.all

    expose sites
  end

  def register
  end

  # Deletes a user existing token, if any.
  def invalidateUserSession(user)
    userSession = Session.find_by_user_id(user.id)
    if !userSession.nil? then
      userSession.delete
    end
  end

  # Generate a user session for the given user and returns a token.
  # This method would scarcely go to the db more than once, if that ever happens.
  def generateUserSession(user, site, customer)

    begin
      token = SecureRandom.hex(20)
      userSession = Session.find_by_token(token)
    end until userSession.nil?

    userSession = Session.new
    userSession.user = user
    userSession.site = site
    userSession.customer = customer
    userSession.token = token
    userSession.save

    return token
  end

  private :generateUserSession, :invalidateUserSession

end
