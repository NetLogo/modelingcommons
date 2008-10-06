class AccountController < ApplicationController

  before_filter :require_login, :except => [:new, :create, :login, :login_action]

  def new
    @new_person = Person.new
  end

  def create
    @new_person = Person.new(params[:new_person])

    begin
      @new_person.save!
      flash[:notice] = "Congratulations, #{@new_person.first_name}!  You are now registered with the Modeling Commons.  We're delighted that you've joined us."
      Notifications.deliver_signup(@new_person)
      session[:person_id] = @new_person.id
      redirect_to :controller => "browse", :action => "index"
    rescue Exception => e
      flash[:notice] = e.message
      redirect_to :back
    end

  end

  def login
  end

  def login_action
    @person =
      Person.find_by_email_address_and_password(params[:email_address].strip,
                                                params[:password].strip)

    if @person.blank?
      flash[:notice] = "Sorry, but no user exists with that e-mail address and password.  Please try again."
      redirect_to :back
      return
    end

    flash[:notice] = "Welcome back to the commons, #{@person.first_name}!"
    session[:person_id] = @person.id
    redirect_to :controller => "account", :action => "mypage"
  end

  def logout
    @person = nil
    session[:person_id] = nil
    flash[:notice] = "You have been logged out.  Please come back soon!"
    redirect_to :controller => "account", :action => "index"
  end

  def mypage
    if params[:id].blank?
      @the_person = @person
    else
      @the_person = Person.find(params[:id].to_i)
    end

    logger.warn "the_person = '#{@the_person.to_yaml}'"
  end

  def reset_password
      dictionary_file = File.new('/etc/dictionaries-common/words', 'r')
      dictionary_file_contents = dictionary_file.read
      dictionary_words  = dictionary_file_contents.split("\n")
    dictionary_words.delete_if { |word| word.length > 5 }

      # Create our password
      word1 = dictionary_words[rand(dictionary_words.length)].strip.downcase
      number = rand 10000
      word2 = dictionary_words[rand(dictionary_words.length)].strip.downcase

      new_password = word1 + number.to_s + word2

      new_password.gsub!(/[^a-z0-9]/, '')

    @person.password = new_password
    @person.save!

    flash[:notice] = "Your password has been reset.  A new password was sent to you via e-mail."
    Notifications.deliver_reset_password(@person)
    redirect_to :controller => "browse", :action => "index"
  end

  def update_password_action
    new_password = params[:new_password]
    new_password_confirmation = params[:new_password_confirmation]

    if new_password != new_password_confirmation
      flash[:notice] = "You did not enter the same password in both fields.  Please try again."
      redirect_to :back
      return
    else
      @person.password = new_password
      flash[:notice] = "Your new password has been set.  A confirmation notice was sent via e-mail."
      Notifications.deliver_changed_password(@person)
      redirect_to :mypage
      begin
        @person.save!
      rescue Exception => e
        flash[:notice] = e.message
        redirect_to :back
      end
    end
  end

end
