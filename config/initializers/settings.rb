require 'yaml'

APP_CONFIG = YAML::load(File.open("#{::Rails.root.to_s}/config/config.yml"))