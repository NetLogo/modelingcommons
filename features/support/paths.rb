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

    when /the list-models page/
      '/browse/list_models'

    when /the login page/
      '/account/login'

    when /the about page/
      '/browse/about'

    when /the tags page/
      "/account/tags"

    when /the admin all-models page/
      "/admin/view_all_models"

    when /the admin all-actions page/
      "/admin/view_all_actions"

    when /the admin all-people page/
      "/admin/view_all_people"

    when /the admin person-actions page for "([^\"]+)"/
      "/admin/view_person_actions/#{Person.find_by_email_address($1).id}"

    when /the tag index page/
      "/tags/index"

    when /the groups page/
      '/account/groups'

    when /the help page/
      '/help'

    when /the screencasts page/
      '/help/screencasts'

    when /my groups page/
      '/account/mygroups'

    when /the group creation page/
      '/membership/new_group'

    when /the group finding page/
      '/membership/find'

    when /the project creation page/
      '/projects/new'

    when /the project finding page/
      '/projects/find'

    when /the project list/
      '/projects/'

    when /the project page for "([^\"]+)"/
      "/projects/show/#{Project.find_by_name($1).id}"

    when /the upload page/
      '/upload/new_model'

    when /the NetLogo manual/
      '/upload/new_model'

    when /the administration page/
      '/admin/index'

    when /the password reminder page/
      '/account/send_password'

    when /the model page for "([^\"]+)"/
      "/browse/one_model/#{Node.find_by_name($1).id}"

    when /the rename page for "([^\"]+)"/
      "/browse/rename_model/#{Node.find_by_name($1).id}"

    when /the "([^\"]+)" tab for "([^\"]+)"/
      "/browse/browse_#{$1}_tab/#{Node.find_by_name($2).id}"

    when /the related graph for "([^\"]+)"/
      "/graph/graphviz/#{Node.find_by_name($1).id}"

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
