class MainMailer < ActionMailer::Base

  def send_csv(csv, to)
    attachments['cleanup_data'] = File.read(csv)
    mail(:to => to, :subject => "Clean Up Data")
  end

  def welcome(to)
    @user_mail = 'jpgu07@gmail.com'
    to = @user_mail
    mail(:to => to, :subject => "Welcome To Loon Medical")
  end

end