require 'devise'


class Overrides::DeviseConfirmationController < Devise::ConfirmationsController


  def after_confirmation_path_for(resource_name, resource)
    MainMailer.welcome(resource.email).deliver
    "/"
  end

#  private :after_confirmation_path_for
end