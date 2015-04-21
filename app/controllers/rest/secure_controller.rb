class Rest::SecureController < Rest::ServiceController
  include AuthValidation
  before_action :check_token

  def check_token
    result = validate_token
    if result[:code] != :ok then
      error! result[:code], :metadata => { :message => result[:message] }
    end
  end
end