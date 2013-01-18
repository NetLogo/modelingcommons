require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  fixtures :people

  should_have_many :postings
  should_have_many :logged_actions
  should_have_many :tags
  should_have_many :tagged_nodes
  should_have_many :recommendations
  should_have_many :email_recommendations
  should_have_many :spam_warnings

  should_have_many :memberships
  should_have_many :groups, :through => :memberships

  should_validate_presence_of :first_name
  should_validate_presence_of :last_name
  should_validate_presence_of :email_address
  should_validate_presence_of :password

  should_validate_uniqueness_of :email_address, :case_sensitive => false
end
