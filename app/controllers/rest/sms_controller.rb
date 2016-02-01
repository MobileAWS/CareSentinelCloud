class Rest::SmsController < Rest::SecureController

  require 'rubygems'
  require 'twilio-ruby'

  AuthValidation.public_access :sms => [:send_sms]

  def send_sms
    return if !checkRequiredParams(:message,:phone_numbers);

      Rails.logger.info 'sending message'
      message= params[:message] if params[:message].present?
      phones= params[:phone_numbers] if params[:phone_numbers].present?

      if phones.kind_of?(Array)
          phones.each do |phone|
             phone_number = phone
             send_message(phone_number, message)
          end
      else
        send_message(phones, message)
      end
  end

    private
    def send_message(phone_number, message)
      @client = ::Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
      message = @client.account.messages.create(
          :from =>  ENV['TWILIO_NUMBER'],
          :to => phone_number,
          :body => message,
          :method => 'GET',
          :fallback_method => 'GET',
          :status_callback_method => 'GET',
          :record => 'false'
      )
      puts message.to
    end

end