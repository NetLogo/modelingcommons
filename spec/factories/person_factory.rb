Factory.define(:person) do |person|
  person.sequence(:first_name) { |n| "first#{n}"}
  person.sequence(:last_name) { |n| "last#{n}"}
  person.password "password"
  person.administrator false

  person.avatar_file_name "avatar"
  person.avatar_content_type "image/jpeg"
  person.avatar_file_size 20
end
