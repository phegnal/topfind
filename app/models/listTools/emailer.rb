class Emailer
  def initialize()
  end
  
  def sendTopFINDer(recipient, attachment)
    require 'net/smtp'

    sender = "topfind.clip@gmail.com"

    marker = "AUNIQUEMARKER12345"


part1 = <<MESSAGE_END
From: TopFIND <#{sender}>
To: recipient <#{recipient}>
Subject: TopFINDer results
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
MESSAGE_END

part2 =<<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit
This is an automated message send to you from the TopFIND database. Attached are results of your TopFINDer analysis.

Have a nice day!

The TopFIND Team
--#{marker}
EOF

    # Read a file and encode it into base64 format
    filecontent = File.read(attachment)
    encodedcontent = [filecontent].pack("m")   # base64

part3 =<<EOF
Content-Type: multipart/mixed; name=\"TopFINDer_Results.zip\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="TopFINDer_Results.zip"

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
