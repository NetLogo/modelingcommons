module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

      # Add more mappings here.
      # Here is a more fancy example:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

    when /the registration page/
      '/account/new'

    when /the login page/
      '/account/login'

    when /the upload page/
      '/upload/new_model'

    when /the administration page/
      '/admin/index'

    when /the password reminder page/
      '/account/send_password'

    when /the page for "([^\"]+)"/
      "/browse/one_model/#{Node.find_by_name($1).id}"

    when /the user page for "([^\"]+)"/
      "/account/mypage/#{Person.find_by_email_address($1).id}"

    when /the login action page/
      "/account/login_action"

    when /the password reminder action page/
      "/account/send_password_action"

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
