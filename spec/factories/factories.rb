# require 'factory_girl'

# Factory.define(:posting) do |posting|
#   posting.association :person
#   posting.association :node
#   posting.sequence(:title) { |n| "title#{n}"}
#   posting.sequence(:body) { |n| "body#{n}"}
#   posting.is_question false
#   posting.deleted_at nil
#   posting.answered_at nil
# end

# Factory.define(:group) do |group|
#   group.sequence(:name) { |n| "tag#{n}"}
# end

# Factory.define(:membership) do |m|
#   m.association :person
#   m.association :group
#   m.is_administrator false
#   m.status "pending"
# end

# Factory.define(:node) do |node|
#   node.sequence(:name) { |n| "name#{n}"}
#   node.association :visibility, :factory => :permission_setting
#   node.association :changeability, :factory => :permission_setting
# end

# Factory.define(:node_version) do |node_version|
#   node_version.description "This is a description"
#   node_version.contents "These are contents"
# end

# Factory.define(:permission_setting) do |p|
#   p.short_form "a"
#   p.name "Everyone"
# end

# Factory.define(:person) do |person|
#   person.sequence(:first_name) { |n| "first#{n}"}
#   person.sequence(:last_name) { |n| "last#{n}"}
#   person.sequence(:email_address) { |n| "email#{n}@example.com"}
#   person.password "password"
#   person.administrator false
#   person.registration_consent true

#   person.avatar_file_name "avatar"
#   person.avatar_content_type "image/jpeg"
#   person.avatar_file_size 20
# end

# Factory.define(:project) do |project|
#   project.sequence(:name) { |n| "tag#{n}"}
# end

# Factory.define(:tag) do |tag|
#   tag.sequence(:name) { |n| "tag#{n}"}
#   tag.association :person
# end

# Factory.define(:tagged_node) do |tn|
#   tn.association :node
#   tn.association :tag
#   tn.association :person
#   tn.sequence(:comment) { |n| "comment#{n}"}
# end
