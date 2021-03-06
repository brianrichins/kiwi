require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

#The config file is not needed on all hosts, so only load it if it is there
config_file = File.expand_path('../application.yml', __FILE__)
if (File.exists?(config_file))
  CONFIG = YAML.load(File.read(config_file))
  CONFIG.merge! CONFIG.fetch(Rails.env, {})
else
  CONFIG = {}
end

require "bson"
require "moped"

Moped::BSON = BSON

module Kiwi
  class Application < Rails::Application
    config.autoload_paths += %W(#{Rails.root}/lib)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end
end
