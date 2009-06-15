class RenameSenderToPersonInEmailRecommendation < ActiveRecord::Migration
  def self.up
    rename_column :email_recommendations, :sender_id, :person_id
  end

  def self.down
    rename_column :email_recommendations, :person_id, :sender_id
  end
end
