Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']

  config.oauth_key = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end
