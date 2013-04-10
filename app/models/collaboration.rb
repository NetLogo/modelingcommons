class Collaboration < ActiveRecord::Base
  validates_presence_of :node_id
  validates_presence_of :person_id
  validates_presence_of :collaborator_type_id

  belongs_to :node
  belongs_to :person
  belongs_to :collaborator_type

  def name
    collaborator_type.name
  end

  after_save :notify_collaborator

  def notify_collaborator
    Notifications.collaboration_notice(node, person).deliver
  end
end
