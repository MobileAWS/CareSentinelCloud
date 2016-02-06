class Rest::SmsController < Rest::SecureController

  AuthValidation.token_action :sms => [:send_sms]

  require 'rubygems'
  require 'twilio-ruby'

  def send_sms
    return if !checkRequiredParams(:message,:phone_numbers);

      message = params[:message]
      phones= params[:phone_numbers] if params[:phone_numbers].present?
      puts 'Make it so Sending SMS to '+phones.to_s+' with message '+message

      if params[:latitude].present? && params[:longitude].present?
        short_link = Bitly.client.shorten("https://maps.google.com/?q=#{params[:latitude]}+#{params[:longitude]}&ll=#{params[:latitude]}+#{params[:longitude]}&output=classic")
        message = "#{message}, alert occurred at #{short_link.short_url}"
      end
      if phones.kind_of?(Array)
          phones.each do |phone|
             phone_number = phone
             phone_number = "+#{phone_number}" unless phone_number.start_with?'+'
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