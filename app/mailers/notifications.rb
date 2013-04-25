# Model for sending e-mail notifications

class Notifications < ActionMailer::Base

  default :from => 'nlcommons@modelingcommons.org'
  
  NLCOMMONS_LIST = 'modelingcommons@ccl.northwestern.edu'

  ActionMailer::Base.smtp_settings = {
    :address => "mail.modelingcommons.org",
    :port => 25,
    :domain => "modelingcommons.org",
    :authentication => :plain,
    :enable_starttls_auto => false
  }

  def wrap_subject(text)
    if Rails.env.production?
      text
    else
      "[#{Rails.env}] #{text}"
    end
  end

  def signup(person, cleartext_password)
    @recipients = person.email_address
    @person = person
    logger.warn "Cleartext password = '#{cleartext_password}'"
    @cleartext_password = cleartext_password

    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject("Welcome to the NetLogo Modeling Commons!"))
  end

  def reset_password(person)
    @recipients = person.email_address
    @person = person
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject('Modeling Commons: Your new password'))
  end

  def password_reminder(person, new_password)
    @recipients = person.email_address
    @person = person
    @new_password = new_password
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject('Modeling Commons: Your password'))
  end

  def changed_password(person)
    @recipients = person.email_address
    @person = person
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject('Your new password'))
  end

  def modified_model(nlmodel, current_author)
    @recipients = nlmodel.people.select {|p| p.send_model_updates?}.map {|person| person.email_address}
    @recipients.delete(current_author.email_address)

    @nlmodel = nlmodel
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject("Modeling Commons: Update to the '#{nlmodel.name}' model"))
  end

  def applied_tag(people, tag)
    @recipients = people.select {|p| p.send_tag_updates?}.map {|person| person.email_address}
    @tag = tag
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject("Modeling Commons: '#{tag.name}' tag was applied"))
  end

  def updated_discussion(nlmodel, current_author)
    subj
    author_addresses = nlmodel.people.map{|person| person.email_address}
    #posting_addresses = nlmodel.active_postings.map {|ap| ap.person}.select {|p| p.send_model_updates?}.map { |p| p.email_address}
    posting_addresses = nlmodel.active_postings.map {|ap| ap.person}.map { |p| p.email_address}
    @recipients = (author_addresses + posting_addresses).uniq
    @recipients.delete(current_author.email_address)

    @nlmodel = nlmodel
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject("Modeling Commons: Updated discussion of the #{nlmodel.name} model"))
  end

  def invited_to_group(person, membership)
    @recipients = person.email_address
    @membership = membership
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject('Group invitation from the NetLogo Modeling Commons'))
  end

  def friend_recommendation(sender, friend_email_address, node)
    @recipients = friend_email_address
    @cc = sender.email_address
    @node = node
    @sender = sender
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject('View an interesting NetLogo model'))
  end

  def recommended_message(recommender, people, model)
    @recipients = recommender.email_address
    @nlmodel = model
    @recommender = recommender
    mail(:to => @recipients,
         :bcc => people.map{|person| person.email_address},
         :subject => wrap_subject("Recommendation for the '#{model.name}' model in the NetLogo Modeling Commons"))
  end

  def spam_warning(node, person)
    @recipients = 'modelingcommons@ccl.northwestern.edu'
    @node = node
    @person = person
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject("Spam reported for the '#{node.name}' model in the NetLogo Modeling Commons"))
  end

  def upload_acknowledgement(node, person)
    @recipients = person.email_address
    @node = node
    @person = person
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject("Thanks for uploading the '#{node.name}' model!"))
  end

  def collaboration_notice(node, person)
    @cc = node.people.map { |p| p.email_address }
    @recipients = person.email_address
    @node = node
    @person = person
    mail(:to => @recipients,
         :bcc => NLCOMMONS_LIST,
         :subject => wrap_subject("You have been added as a collaborator to the '#{node.name}' model"))
  end

end
