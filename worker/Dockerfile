FROM php:7.1-alpine
MAINTAINER Rodrigo Alfonso

WORKDIR /opt/php

# Install PHPUnit 7
RUN wget -O phpunit https://phar.phpunit.de/phpunit-7.phar && \
            chmod +x phpunit && \
            mv phpunit /usr/local/bin/phpunit

# Install Composer & PHP-Parser
COPY install-composer.sh install-composer.sh

RUN ./install-composer.sh && \
    php composer.phar require nikic/php-parser && \
    ln -s /opt/php/vendor/bin/php-parse /usr/local/bin/php-parse && \
    rm install-composer.sh

# ---

# CHEAT SHEET

# Install PHP Autoload Builder
  # RUN wget -O phpab https://github.com/theseer/Autoload/releases/download/1.25.0/phpab-1.25.0.phar
  # RUN chmod +x phpab
  # RUN mv phpab /usr/local/bin/phpab

# Generate autoload.php for multiple files
  # phpab --output src/autoload.php src
  # phpunit --bootstrap src/autoload.php tests/EmailTest
