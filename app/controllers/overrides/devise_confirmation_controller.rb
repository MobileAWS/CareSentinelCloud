require 'devise'


class Overrides::DeviseConfirmationController < Devise::ConfirmationsController


  def after_confirmation_path_for(resource_name, resource)
    if @user.user_type_id
      userType = Role.find(@user.user_type_id)
      if userType
        if userType.name == "Pro"
          return "/mobile.html#pro"
        end
        if userType.name == "Customer"
          return "/mobile.html"
        end
        if userType.name == "Administrator"
          return '/admin/login.html'
        end
      end
    end
  end

  private :after_confirmation_path_for
end