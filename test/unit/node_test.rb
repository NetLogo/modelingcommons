require 'test_helper'

class NodeTest < ActiveSupport::TestCase

  should belong_to :group
         
  should belong_to :visibility
  should belong_to :changeability
         
  should_have_many :postings
  should_have_many :active_postings
  should_have_many :tagged_nodes
  should_have_many :tags, :through => :tagged_nodes
  should_have_many :email_recommendations
  should_have_many :recommendations
  should_have_many :spam_warnings
  should_have_many :logged_actions
         
  should validate_presence_of :name
  should validate_presence_of :visibility_id
  should validate_presence_of :changeability_id
         
  should validate_numericality_of :visibility_id
  should validate_numericality_of :changeability_id

end
