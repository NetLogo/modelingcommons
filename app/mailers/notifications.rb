# -*- coding: utf-8 -*-
# Model for sending e-mail notifications

class Notifications < ActionMailer::Base

  default :from => 'nlcommons@modelingcommons.org'

  def subject_wrapper(text)
    "[TESTING] " + text
  end

  ActionMailer::Base.smtp_settings = {
    :address => "mail.modelingcommons.org",
    :port => 25,
    :domain => "modelingcommons.org",
    :authentication => :plain,
    :enable_starttls_auto => false
  }

  def signup(person, cleartext_password)
    @person = person
    @cleartext_password = cleartext_password

    mail(:to => person.email_address,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper("Welcome to the NetLogo Modeling Commons!"))
  end

  def reset_password(person)
    @person = person
    mail(:to => person.email_address,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper('Modeling Commons: Your new password'))
  end

  def password_reminder(person, new_password)
    @person = person
    @new_password = new_password
    mail(:to => person.email_address,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper('Modeling Commons: Your password'))
  end

  def changed_password(person)
    @person = person
    mail(:to => person.email_address,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject =>  subject_wrapper('Your new password'))
  end

  def modified_model(nlmodel, current_author)
    @recipients = nlmodel.people.select {|p| p.send_model_updates?}.map {|person| person.email_address}
    @recipients.delete(current_author.email_address)
    @nlmodel = nlmodel
    mail(:to => @recipients,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper("Modeling Commons: Update to the '#{nlmodel.name}' model"))
  end

  def applied_tag(people, tag)
    @recipients = people.select {|p| p.send_tag_updates?}.map {|person| person.email_address}
    @tag = tag
    mail(:to => @recipients,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper("Modeling Commons: '#{tag.name}' tag was applied"))
  end

  def updated_discussion(nlmodel, current_author)
    author_addresses = nlmodel.people.map{|person| person.email_address}
    posting_addresses = nlmodel.active_postings.map {|ap| ap.person}.map { |p| p.email_address}
    @recipients = (author_addresses + posting_addresses).uniq
    @recipients.delete(current_author.email_address)
    @nlmodel = nlmodel
    mail(:to => @recipients,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper("Modeling Commons: Updated discussion of the #{nlmodel.name} model"))
  end

  def invited_to_group(person, membership)
    @membership = membership
    mail(:to => person.email_address,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject =>  subject_wrapper('Group invitation from the NetLogo Modeling Commons'))
  end

  def friend_recommendation(sender, friend_email_address, node)
    @node = node
    @sender = sender
    mail(:to => friend_email_address,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :cc => sender.email_address,
         :subject => subject_wrapper('View an interesting NetLogo model')
         )
  end

  def recommended_message(recommender, people, model)
    @recipients = recommender.email_address
    @subject = "Recommendation for the '#{model.name}' model in the NetLogo Modeling Commons"
    @subject = "[TESTING] #{@subject}" if Rails.env == 'development'
    @nlmodel = model
    @recommender = recommender
    mail(:to => @recipients,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => @subject)
  end

  def spam_warning(node, person)
    @node = node
    @person = person
    mail(:to => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper("Spam reported for the '#{node.name}' model in the NetLogo Modeling Commons")
         )
  end

  def upload_acknowledgement(node, person)
    @node = node
    @person = person
    mail(:to => person.email_address,
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => @subject = subject_wrapper("Thanks for uploading the '#{node.name}' model!")
)
  end

  def collaboration_notice(node, person)
    @node = node
    @person = person
    mail(:to => person.email_address,
         :cc => node.people.map { |p| p.email_address },
         :bcc => 'modelingcommons@ccl.northwestern.edu',
         :subject => subject_wrapper("You have been added as a collaborator to the '#{node.name}' model"))
  end
end
