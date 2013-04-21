# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

STDERR.puts "--- Now seeding!"

PermissionSetting.create([{ :name => 'Everyone', :short_form => 'a'},
                          { :name => 'No one but yourself', :short_form => 'u' },
                          { :name => 'Members of your group', :short_form => 'g' }])

CollaboratorType.create([{ :name => 'Author'},
                         { :name => 'Domain expert'},
                         { :name => 'Advisor'},
                         { :name => 'Teacher'},
                         { :name => 'Editor'},
                         { :name => 'Team member'}])
STDERR.puts "--- Done seeding!"
