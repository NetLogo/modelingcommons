class NewsItem < ActiveRecord::Base
  belongs_to :person

  validates_presence_of :person
end
