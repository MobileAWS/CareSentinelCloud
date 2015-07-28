class MainMailer < ActionMailer::Base

  def send_csv(csv, to)
    attachments['cleanup_data'] = File.read(csv)
    mail(:to => to, :subject => "Clean Up Data")
  end

end