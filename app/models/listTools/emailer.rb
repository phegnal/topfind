class Emailer
  def initialize()
  end
  
  def send(recipients, attachments)
    require 'net/smtp'

    # recipients needs to be an array!
    if recipients.class == String
      recipients = [recipients]
    end
    sender = "topfind.clip@gmail.com"

message = <<MESSAGE_END
From: TopFIND <#{sender}>
To: #{recipients.join(", ")}
Subject: test email

This is an automated message send to you from the TopFIND database. Attached are some documents related to your analysis.

Have a nice day!

The TopFIND Team
MESSAGE_END

    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls

    smtp.start('gmail.com', sender,'g3lat1na') do |smtp|
      smtp.send_message message, sender, recipients
    end
  end
end
