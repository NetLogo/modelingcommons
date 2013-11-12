# Model to keep track of discussion postings

class Posting < ActiveRecord::Base
  attr_accessible :title, :body, :node_id, :is_question, :person_id, :deleted_at

  belongs_to :node
  belongs_to :person

  validates :title, :presence => true
  validates :body, :presence => true
  validates :node_id, :presence => true

  scope :questions, :conditions => { :is_question => true }, :order => "created_at DESC"
  scope :unanswered_questions, :conditions => { :is_question => true, :answered_at => nil }, :order => "created_at DESC"

  scope :created_since, lambda { |since| { :conditions => ['created_at >= ? ', since] }}

  before_validation :strip_bad_tags
  after_save :notify_people
  after_save :tweet_posting

  def was_answered?
    !!self.answered_at
  end

  def first_posting?
    node.postings.count == 1
  end

  def new_thing
    {:id => id,
      :node_id => node_id,
      :node_name => node.name,
      :date => created_at,
      :description => "Posting by '#{person.fullname}' about the '#{node.name}' model",
      :title => title,
      :contents => body}
  end

  def notify_people
    Notifications.updated_discussion(node, person).deliver
  end

  def strip_bad_tags
    attributes.each do |name, value|
      %w(link script style form input textarea button img).each do |bad_word|
        if value.to_s =~ /(<\s*#{bad_word})/i
          STDERR.puts "'#{bad_word}' found in '#{name}' = '#{value}'"
          self.send("#{name}=".to_sym, attributes[name].gsub($1, "&amp;#{bad_word}"))
        end
      end
    end
  end

  def tweet_posting
    return unless node.world_visible?
    Twitter.update("#{person.fullname} wrote about #NetLogo model #{node.name}, at #{node.url}")
  end

end
