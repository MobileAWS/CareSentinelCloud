class AuthenticationController < Rest::ServiceController

  require 'securerandom'

  # Uses devise to log in the user into the system. This is the only place
  # where devise auth is actually used, the rest of the auth should be done with a valid
  # token. This action returns a token for the user. Devise, however, is used for other tasks,
  # like confirm user / recover a pwd

  def new
    user = User.find_for_database_authentication(:email => params[:email])
    if user.nil? then
      expose :message=>'User or password incorrect', :error=>true
      return;
    end

    # Invalidate any session the user ha now
    invalidateUserSession user

    # Validate the password, as you can see, if the password is wrong, the user seession is already
    # gone, this can improve security.
    if !user.valid_password?(params[:password]) then
      expose :message=>'User or password incorrect', :error=>true
      return;
    end

    if params[:user_type] then
      if user.user_type_name.downcase != params[:user_type].downcase
        expose :message=>"Only '#{params[:user_type].capitalize}' Users are available to use this app", :error => true
        return
      end
    end


    # Create a new session
    token = generateUserSession user
    expose :token => token, :user => user
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
  def generateUserSession(user)

    begin
      token = SecureRandom.hex(20)
      userSession = Session.find_by_token(token)
    end until userSession.nil?

    userSession = Session.new
    userSession.user = user
    userSession.token = token
    userSession.save

    return token
  end

  private :generateUserSession, :invalidateUserSession

end
