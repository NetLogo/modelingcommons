class Collaboration < ActiveRecord::Base
  validates :node_id, :presence => true
  validates :person_id, :presence => true
  validates :collaborator_type_id, :presence => true

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
