README for validates_email
==========================

validates_email extends active record with email validation functionality.  It has 3 levels of validation.

	* level 1 - regex validation of the string format of the email address
	* level 2 - checks the email's domain name and ensures it has mail servers
	* level 3 - checks to see if the domain's mail servers have a record of the email address
	
Level 2 is the Default as level 3 has only had limited testing.

Install
	gem install validates_email

Configuration
In the model file:
	
	gem 'validates_email'
	require 'validates_email'
	
	class User < ActiveRecord::Base	
		validates_email :email
		...
	end

This sets a validation method on the email attribute of the User model that validates on save with level 2 validation.
	
You could set it to validate on create with only level 1 validation
	validates_email :email, :on => :create, :level => 1
	
	Level 3 requires a little more.  It requires a from email address to give to the mail servers in the verification process.  
	
	validates_email :email, :level => 3, :from=>"example@example.com"
	
Level 3 also has an extra option that defaults to true.  It is pass_on_unable_to_verify.  By default level 3 validation allows emails to pass verification when there are some issues talking with a specific domains email server.  Some servers don't like to talk to strangers, so it can be difficult to determine if an email is invalid or the server doesn't want to play nice.  By default the emails should pass verification if this occurs.  You can disable this:

	validates_email :email, :level => 3, :from=>"example@example.com", :pass_on_unable_to_verify=>false
	
	