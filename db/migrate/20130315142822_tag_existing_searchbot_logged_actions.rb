class TagExistingSearchbotLoggedActions < ActiveRecord::Migration
  def self.up
    add_index :logged_actions, :is_searchbot
    LoggedAction.update_all('is_searchbot = true', 
                            "browser_info ~* 'bot|yandex|baidu|yahoo|search|crawl|spider'")
  end

  def self.down
  end
end
