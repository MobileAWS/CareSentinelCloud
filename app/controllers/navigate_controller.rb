class NavigateController < ApplicationController

  include AuthValidation

  AuthValidation.public_access :user => [:login, :reset_password]

  before_action :check_token, :except => [:login, :reset_password]

  def check_token
    result = validate_token
    if result[:code] != :ok then
      redirect_to "/"
      return
    end
  end

  def login
  end

  def home
    MainMailer.welcome('').deliver
     @site = getCurrentSite
     @role = getCurrentRole
     @customer = getCurrentCustomer
     @token = params[:token]
     render getRoleId+'/home'
  end

  def reset_password
    render 'navigate/reset_password'
  end

  def view
    @site = getCurrentSite
    render getRoleId+"/main/#{params[:entityName].pluralize.downcase}", :layout => false
  end

  def add_edit
    @customer = getCurrentCustomer
    entity_from_parameters
    render getRoleId+"/add_edit/#{params[:entityName].pluralize.downcase}", :layout => false
  end

  def details
    entity_from_parameters
    render getRoleId+"/details/#{params[:entityName].pluralize.downcase}", :layout => false
  end

  def entity_from_parameters
    entityName = params[:entityName]
    entityName = entityName.camelize
    entityClass = entityName.constantize

    if !params[:entityId].nil? then
      @targetEntity = entityClass.find(params[:entityId].to_i)
      @targetEntity.fillExtraData! if entityClass.method_defined? :fillExtraData!
    else
      @targetEntity = entityClass.new
    end
  end

  def getRoleId
    return getCurrentRole.role_id
  end

  private :getRoleId

end
