require File.expand_path("../boot", __FILE__)

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Myblog
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja
    config.i18n.locale = :ja
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]
    config.cache_store = :redis_store,
      config.database_configuration[Rails.env]["redis"]["host"],
      config.database_configuration[Rails.env]["redis"]["options"]
  end
end
