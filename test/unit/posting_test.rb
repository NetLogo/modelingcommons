require 'test_helper'

class PostingTest < ActiveSupport::TestCase
  should belong_to :node
  should belong_to :person
         
  should validate_presence_of :title
  should validate_presence_of :body

end
