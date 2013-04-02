# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

PermissionSetting.create([{ :name => 'Everyone' },
                          { :name => 'No one but yourself' },
                          { :name => 'Members of your group' }])

CollaboratorType.create([{ :name => 'Author'},
                         { :name => 'Domain expert'},
                         { :name => 'Advisor'},
                         { :name => 'Teacher'},
                         { :name => 'Editor'},
                         { :name => 'Team member'}])
