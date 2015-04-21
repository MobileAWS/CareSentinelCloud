require 'devise'

class Overrides::DevisePasswordsController < Devise::PasswordsController


  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end

  protected
  def after_resetting_password_path_for(resource_name)
    user = User.find_by_email resource.email
    return "/"
  end
end