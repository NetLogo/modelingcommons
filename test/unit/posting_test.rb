require 'test_helper'

class PostingTest < ActiveSupport::TestCase
  should_belong_to :node
  should_belong_to :person

  should_validate_presence_of :title
  should_validate_presence_of :body

end
