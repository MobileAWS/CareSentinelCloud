class Rest::SmsController < Rest::SecureController

  require 'rubygems'
  require 'twilio-ruby'

  def send_sms
    return if !checkRequiredParams(:message,:phone_numbers);

      message= params[:message] if params[:message].present?
      phones= params[:phone_numbers] if params[:phone_numbers].present?
      Rails.logger.info 'Make it so Sending SMS to '+phones.to_s+' with message '+message

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

      begin
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
        rescue Twilio::REST::RequestError => e
          puts e.message
      end
    end

end