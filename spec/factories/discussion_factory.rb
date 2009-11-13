Factory.define(:posting) do |posting|
  posting.association :person
  posting.association :node
  posting.sequence(:title) { |n| "title#{n}"}
  posting.sequence(:body) { |n| "body#{n}"}
  posting.is_question false
  posting.deleted_at nil
  posting.answered_at nil
end
