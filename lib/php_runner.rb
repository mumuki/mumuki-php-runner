require 'mumukit'

Mumukit.runner_name = 'php'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-php-worker:1.4'
end

require_relative './version'
require_relative './metadata_hook'
require_relative './php_file_hook'
require_relative './precompile_hook'
require_relative './test_hook'
require_relative './expectations_hook'
require_relative './query_hook'
