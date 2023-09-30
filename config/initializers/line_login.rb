Devise.setup do |config|
  config.omniauth :line, ENV['LINE_LOGIN_CHANNEL_ID'], ENV['LINE_LOGIN_CHANNEL_SECRET']
end