require 'digest'

module AuthValidation

  @currentUser

  def getCurrentUser
    if !@currentUser.nil?
      return @currentUser
    else
      return Session.find_by_token(params[:token]).user
    end

  end

  def setCurrentUser(user)
    @currentUser = user
  end

  def getCurrentRole
    if !@currentUser.nil?
        return @currentUser.role
    else
      return Session.find_by_token(params[:token]).user.role
    end
  end

  def getCurrentSite
    return Session.find_by_token(params[:token]).site
  end

  def validate_token

    controllerSymbol = controller_name.to_sym

    if  @@public_access.has_key? controllerSymbol then
      tmpVal = @@public_access[controllerSymbol]
      if !tmpVal.nil? && tmpVal.index(action_name.to_sym) != nil then
        return {:code => :ok}
      end
    end


    default_fail = false;
    if  @@token_actions.has_key? controllerSymbol then
      #Validate if this action is available thru token header validation
      token_header = env['HTTP_APP_TOKEN']
      token_timestamp = env['HTTP_APP_TIMESTAMP']
      default_fail = true;
      if !token_header.nil? && !token_timestamp.nil? then
        tmpVal = @@token_actions[controllerSymbol]
        if !tmpVal.nil? && tmpVal.index(action_name.to_sym) != nil then
          base_info = '{"environment":"'+Rails.env.to_s+'","action":"'+action_name+'","timestamp":"'+token_timestamp+'"}';
          return {:code => :forbidden, :message => 'Invalid token'} if token_header != Digest::MD5.hexdigest(base_info)
          return {:code => :ok}
        end
      end
    end

    token = params[:token]
    if token.nil? then
      return {:code => :unauthenticated, :message => 'No token specified'}
    end

    userSession = Session.find_by_token token
    if userSession.nil? then
      return {:code => :forbidden, :message => 'Invalid token'}
    end

    if  @@admin_actions.has_key? controllerSymbol then
      tmpVal = @@admin_actions[controllerSymbol]
      if !tmpVal.nil? && tmpVal.index(action_name.to_sym) != nil then
          return {:code => :forbidden, :message => 'You need admin priveleges to perform this action'} if !userSession.user.isAdmin?
          default_fail = false;
      end
    end

    return {:code => :forbidden, :message => "You don't have permissions for this action"} if default_fail
    @currentUser = userSession.user
    return {:code => :ok}
  end

  @@admin_actions = {}
  @@public_access = {}
  @@token_actions = {}

  def self.admin_access(name)
    # Admin actions field
    @@admin_actions = @@admin_actions.merge(name)
  end

  def self.public_access(name)
    # Public actions field
    @@public_access = @@public_access.merge(name)
  end

  def self.token_action(name)
    # Admin actions field
    @@token_actions = @@token_actions.merge(name)
  end


end