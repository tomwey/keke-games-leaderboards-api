require 'bundler/setup'
env = ENV["RACK_ENV"] || "development"
Bundler.require(:default, env.to_sym)
require_all "app/models/*"
require_all "app/apis/*"

class KeKeGameLeaderboardAPI < Grape::API
  mount KeKeGameLeaderboard::LeaderboardsAPI
  mount KeKeGameLeaderboard::UsersAPI
end

class Application < Goliath::API
  def response(env)
    ::KeKeGameLeaderboardAPI.call(env)
  end
end