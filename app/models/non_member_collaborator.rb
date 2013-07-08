class NonMemberCollaborator < ActiveRecord::Base
  attr_accessible :email, :name

  validates :email, presence:true, uniqueness:true, email: { allow_nil:false, allow_blank:false }

  has_many :non_member_collaborations
  has_many :nodes, :through => :non_member_collaborations

  def email_address
    email
  end

  def fullname
    name
  end

  def display_name
    if name.present?
      "#{name}, #{email}"
    else
      email
    end
  end

end
