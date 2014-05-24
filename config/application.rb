env = ENV["RACK_ENV"] || "production"
config = YAML::load(File.open('config/database.yml'))[env]
ActiveRecord::Base.establish_connection(config)