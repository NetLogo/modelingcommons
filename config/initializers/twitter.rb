Twitter.configure do |config|
  config.consumer_key = ENV['twitter_consumer_key']
  config.consumer_secret = ENV['twitter_consumer_secret']

  config.consumer_key = ENV['twitter_oauth_token']
  config.consumer_secret = ENV['twitter_oauth_token_secret']
end
