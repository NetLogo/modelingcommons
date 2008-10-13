class MakeAdminFalseByDefault < ActiveRecord::Migration
  def self.up
    change_column_default :memberships, :is_administrator, false
  end

  def self.down
  end
end
