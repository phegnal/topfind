class Emailer
  def initialize()
  end
  
  def sendTopFINDerConfirmation(recipient, label)
    require 'net/smtp'

    sender = "topfind.clip@gmail.com"

    marker = "AUNIQUEMARKER12345"

part1 = <<MESSAGE_END
From: TopFIND <#{sender}>
To: recipient <#{recipient}>
Subject: TopFINDer analysis #{label}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
MESSAGE_END

part2 =<<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit
Dear TopFIND user,

This is an automated message confirming that your analysis in TopFINDer is running. 
Your data are currently being processed and the results will be sent to you shortly (15 minutes to 2 hours).
In case of questions please respond to this email!
  
Best regards,

The TopFIND Team
--#{marker}
EOF

    mailtext = part1 + part2
    
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_starttls

    smtp.start('gmail.com', 'topfind.clip@gmail.com','g3lat1na') do |smtp|
      smtp.sendmail(mailtext, 'topfind.clip@gmail.com',
      recipient)
    end
    
    return(true)
  end
  
  def sendTopFINDerResults(recipient, attachment, label)
    require 'net/smtp'

    sender = "topfind.clip@gmail.com"

    marker = "AUNIQUEMARKER12345"


part1 = <<MESSAGE_END
From: TopFIND <#{sender}>
To: recipient <#{recipient}>
Subject: TopFINDer analysis #{label}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
MESSAGE_END

part2 =<<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit
Dear TopFIND user,

This is an automated message send to you from the TopFIND database. Attached you will find the results of your TopFINDer analysis.
For your reference or an explanation of the analysis, please see this article: http://nar.oxfordjournals.org/content/early/2014/10/26/nar.gku1012.
In case of further questions, please respond to this email.

Best regards,

The TopFIND Team
--#{marker}
EOF

    # Read a file and encode it into base64 format
    filecontent = File.read(attachment)
    encodedcontent = [filecontent].pack("m")   # base64

part3 =<<EOF
Content-Type: multipart/mixed; name=\"#{label}.zip\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{label}.zip"

#{encodedcontent}
--#{marker}--
EOF

	mailtext = part1 + part2 + part3
	
    begin 
      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls

      smtp.start('gmail.com', 'topfind.clip@gmail.com','g3lat1na') do |smtp|
        smtp.sendmail(mailtext, 'topfind.clip@gmail.com',
        recipient)
      end
    rescue Exception => e  
      print "TopFIND mailer exception occured: " + e  
    end  
  end
end
