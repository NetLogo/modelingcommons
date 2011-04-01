# Model for sending e-mail notifications

class Notifications < ActionMailer::Base

  ActionMailer::Base.smtp_settings = {
    :address => "mail.modelingcommons.org",
    :port => 25,
    :domain => "modelingcommons.org",
    :authentication => :plain,
    :enable_starttls_auto => false
  }

  FROM_ADDRESS = 'nlcommons@modelingcommons.org'

  def standard_settings
    @from = FROM_ADDRESS
    @sent_on = Time.now()
    @content_type = 'text/html'
  end

  def signup(person, cleartext_password)
    standard_settings
    @recipients = person.email_address
    @bcc = 'reuven@lerner.co.il'
    @subject = "Welcome to the NetLogo Modeling Commons!"
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'

    @body[:person] = person
    logger.warn "Cleartext password = '#{cleartext_password}'"
    @body[:cleartext_password] = cleartext_password
  end

  def reset_password(person)
    standard_settings
    @recipients = person.email_address
    @body[:person] = person
    @subject = 'Your new password'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
  end

  def password_reminder(person, new_password)
    standard_settings
    @recipients = person.email_address
    @body[:person] = person
    @body[:new_password] = new_password
    @subject = 'Your password'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
  end

  def changed_password(person)
    standard_settings
    @recipients = person.email_address
    @body[:person] = person
    @subject = 'Your new password'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
  end

  def modified_model(people, node)
    standard_settings
    @recipients = node.people
    @subject = 'Model update'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
    @body[:nlmodel] = node
  end

  def applied_tag(people, tag)
    standard_settings
    @recipients = people.map{|person| person.email_address}
    @subject = 'Tag was applied'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
    @body[:tag] = tag
  end

  def updated_discussion(people, nlmodel)
    standard_settings
    @recipients = people.map{|person| person.email_address}
    @subject = 'Updated discussion'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
    @body[:nlmodel] = nlmodel
  end

  def invited_to_group(person, membership)
    standard_settings
    @recipients = person.email_address
    @subject = 'Group invitation from the NetLogo Modeling Commons'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
    @body[:membership] = membership
  end

  def friend_recommendation(sender, friend_email_address, node)
    standard_settings
    @recipients = friend_email_address
    @cc = sender.email_address
    @subject = 'View an interesting NetLogo model'
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
    @body[:node] = node
    @body[:sender] = sender
  end

  def recommended_message(recommender, people, model)
    standard_settings
    @recipients = recommender.email_address
    @bcc = people.map{|person| person.email_address}
    @subject = "Recommendation for the '#{model.name}' model in the NetLogo Modeling Commons"
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
    @body[:nlmodel] = model
    @body[:recommender] = recommender
  end

end
