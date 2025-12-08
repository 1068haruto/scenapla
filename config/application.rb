require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Scenapla
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # view_models/のオートロード（開発 & テスト環境）
    config.autoload_paths << Rails.root.join("app", "view_models")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # field_with_errorsクラス（Railsのバリデーションエラーで自動付与）による、フォーム構造の変更防止
    config.action_view.field_error_proc = Proc.new { |html_tag, _instance| html_tag.html_safe }

    # アプリのデフォルト言語を日本語に
    config.i18n.default_locale = :ja
  end
end
