require 'devise'


class Overrides::DeviseConfirmationController < Devise::ConfirmationsController


  def after_confirmation_path_for(resource_name, resource)
    "/"
  end

#  private :after_confirmation_path_for
end