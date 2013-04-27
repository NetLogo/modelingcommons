class AddFullTextIndexes < ActiveRecord::Migration
  def up
    execute "CREATE INDEX ON Versions USING gin(to_tsvector('english', contents));"
  end

  def down
  end
end
