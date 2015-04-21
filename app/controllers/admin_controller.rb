class AdminController < ApplicationController
  layout 'admin'
  include AuthValidation

  AuthValidation.public_access :admin => [:login]
  AuthValidation.admin_access :admin => [:home]

  before_action :check_token

  def check_token
    result = validate_token
    if result[:code] != :ok then
      redirect_to "/admin"
      return
    end
  end

  def login
  end
  def home
  end
  def view
    render "admin/main/#{params[:entityName].pluralize}", :layout => false
  end
  def add_edit
    entity_from_parameters
    render "admin/add_edit/#{params[:entityName].pluralize}", :layout => false
  end

  def details
    entity_from_parameters
    render "admin/details/#{params[:entityName].pluralize}", :layout => false
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
  
 end