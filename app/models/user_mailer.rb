class UserMailer < ActionMailer::Base
  
  def forgot_password(user, key)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host
    @subject    = "TopFIND -- forgotten password"
    @body       = { :user => user, :key => key, :host => host, :app_name => app_name }
    @recipients = user.email_address
    @from       = "no-reply@#{host}"
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def new_submission(user,import)
    @subject    = "TopFIND -- new data submitted"
    @body       = { :user => user, :import => import }
    @recipients = 'lange.philipp@gmail.com'
    @from       = "plange@interchange.ubc.ca"
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def new_submission_confirmation(user,import)
    @subject    = "TopFIND -- new data submitted"
    @body       = { :user => user, :import => import }
    @recipients = user.email_address
    @from       = "plange@interchange.ubc.ca"
    @sent_on    = Time.now
    @headers    = {}
  end 

end
