class MainMailer < ActionMailer::Base

  def send_csv(csv)
    attachments['cleanup_data'] = File.read(csv)
    mail(:to => 'jpgu07@gmail.com', :subject => "Clean Up Data")
  end

end