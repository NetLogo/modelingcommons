require 'test_helper'

class NodeTest < ActiveSupport::TestCase

  should_belong_to :node_type
  should_belong_to :group

  should_belong_to :visibility
  should_belong_to :changeability

  should_have_many :node_versions
  should_have_many :postings
  should_have_many :active_postings
  should_have_many :tagged_nodes
  should_have_many :tags, :through => :tagged_nodes
  should_have_many :email_recommendations
  should_have_many :recommendations
  should_have_many :spam_warnings
  should_have_many :logged_actions

  should_validate_presence_of :name
  should_validate_presence_of :node_type_id
  should_validate_presence_of :visibility_id
  should_validate_presence_of :changeability_id

  should_validate_numericality_of :node_type_id
  should_validate_numericality_of :visibility_id
  should_validate_numericality_of :changeability_id

end
