class NonMemberCollaboration < ActiveRecord::Base
  attr_accessible :collaborator_type_id, :node_id, :non_member_collaborator_id, :person_id

  validates :collaborator_type_id, presence:true, numericality:true
  validates :node_id, presence:true, numericality:true
  validates :non_member_collaborator_id, presence:true, numericality:true
  validates :person_id, presence:true, numericality:true

  belongs_to :collaborator_type
  belongs_to :node
  belongs_to :non_member_collaborator
  belongs_to :person

  def name
    collaborator_type.name
  end

  after_save :notify_collaborator

  def notify_collaborator
    Notifications.nonmember_collaboration_notice(node, non_member_collaborator, person).deliver
  end

end
