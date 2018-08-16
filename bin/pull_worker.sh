#!/bin/bash

TAG=$(grep -e 'mumuki/mumuki-php-worker:[0-9]*\.[0-9]*' ./lib/php_runner.rb -o | tail -n 1)

echo "Pulling $TAG..."
docker pull $TAG
