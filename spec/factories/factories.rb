  include ActionDispatch::TestProcess

  FactoryGirl.define do 

    factory :posting do
      association :person
      association :node
      sequence(:title) { |n| "title#{n}"}
      sequence(:body) { |n| "body#{n}"}
      is_question false
      deleted_at nil
      answered_at nil
    end

    factory :group do
      sequence(:name) { |n| "tag#{n}"}
    end

    factory :membership do
      association :person
      association :group
      is_administrator false
      status "pending"
    end

    factory :node do
      sequence(:name) { |n| "name#{n}"}
      association :visibility, :factory => :permission_setting
      association :changeability, :factory => :permission_setting
    end

    factory :version do
      contents "These are contents"
    end

    factory :permission_setting do
      short_form "a"
      name "Everyone"
    end

    factory :person do
      sequence(:first_name) { |n| "first#{n}"}
      sequence(:last_name) { |n| "last#{n}"}
      sequence(:email_address) { |n| "email#{n}@example.com"}
      password "password"
      administrator false
      registration_consent true
      salt 'salt'
      sex 'm'
      country_name 'Israel'

      avatar { fixture_file_upload(Rails.root.join('app', 'assets', 'images', 'person.jpeg'), 'image/jpeg') }


      avatar_file_name "avatar"
      avatar_content_type "image/jpeg"
      avatar_file_size 20
    end

    factory :project do
      sequence(:name) { |n| "tag#{n}"}
    end

    factory :tag do
      sequence(:name) { |n| "tag#{n}"}
      association :person
    end

    factory :tagged_node do
      association :node
      association :tag
      association :person
      sequence(:comment) { |n| "comment#{n}"}
    end


  end

