require 'mumukit'
require 'erb'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

Mumukit.runner_name = 'php'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-php-worker:1.0'
  config.content_type = 'html'
  config.structured = true
end

require_relative './php'
require_relative './extensions/string'
require_relative './assets_server'
require_relative './render/with_renderer'
require_relative './render/html_board'
require_relative './render/html_renderer'

require_relative './multiple_executions_runner'

require_relative './metadata_hook'
require_relative './precompile_hook'
require_relative './test_hook'
require_relative './version_hook'
require_relative './expectations_hook'
require_relative './checker'
