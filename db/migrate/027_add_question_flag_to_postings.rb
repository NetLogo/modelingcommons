class AddQuestionFlagToPostings < ActiveRecord::Migration
  def self.up
    add_column :postings, :is_question, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :postings, :is_question
  end
end
