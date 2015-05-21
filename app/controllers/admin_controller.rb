class AdminController < ApplicationController
  layout 'admin'
  include AuthValidation

  before_action :check_token

  def check_token
    result = validate_token
    if result[:code] != :ok then
      redirect_to "/"
      return
    end
  end

 end