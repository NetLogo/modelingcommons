class Notifications < ActionMailer::Base

  def signup(person)
    @recipients = person.email_address
    @bcc = 'reuven@lerner.co.il'
    @from = "nlcommons@monk.ccl.northwestern.edu"
    @subject = "Welcome to the commons!"
    @body[:person] = person
    @sent_on    = Time.now()
    @content_type = 'text/html'
  end

  def reset_password(person)
    @recipients = person.email_address
    @from = "nlcommons@monk.ccl.northwestern.edu"
    @body[:person] = person
    @subject    = 'Your new password'
    @sent_on    = Time.now()
    @content_type = 'text/html'
  end

  def changed_password(person)
    @recipients = person.email_address
    @from = "nlcommons@monk.ccl.northwestern.edu"
    @body[:person] = person
    @subject    = 'Your new password'
    @sent_on    = Time.now()
    @content_type = 'text/html'
  end

  def modified_model(people, nlmodel)
    @recipients = people.map{|p| p.email_address}
    @from = "nlcommons@monk.ccl.northwestern.edu"
    @subject    = 'Model update'
    @body[:nlmodel] = nlmodel
    @sent_on    = Time.now()
    @content_type = 'text/html'
  end

  def applied_tag(people, tag)
    @recipients = people.map{|p| p.email_address}
    @from = "nlcommons@monk.ccl.northwestern.edu"
    @subject    = 'Tag was applied'
    @body[:tag] = tag
    @sent_on    = Time.now()
    @content_type = 'text/html'
  end

  def updated_discussion(people, nlmodel)
    @recipients = people.map{|p| p.email_address}
    @from = "nlcommons@monk.ccl.northwestern.edu"
    @subject    = 'Updated discussion'
    @body[:nlmodel] = nlmodel
    @sent_on    = Time.now()
    @content_type = 'text/html'
  end

  def invited_to_group(person, membership)
    @recipients = person.email_address
    @from = "nlcommons@monk.ccl.northwestern.edu"
    @subject    = 'Group invitation from the NetLogo Modeling Commons'
    @body[:membership] = membership
    @sent_on    = Time.now()
    @content_type = 'text/html'
  end

end
