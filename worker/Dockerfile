FROM php:7.1-alpine
MAINTAINER Rodrigo Alfonso

WORKDIR /opt/php

# Copy a script to run 'test' and 'ast' requests as batch
COPY run-tests-and-get-ast.sh /usr/local/bin/run-tests-and-get-ast

# Copy a script to install composer
COPY install-composer.sh install-composer.sh

# Install PHPUnit 7, Composer, PHP-Parser, and bash
RUN wget -O phpunit https://phar.phpunit.de/phpunit-7.phar && \
            chmod +x phpunit && \
            mv phpunit /usr/local/bin/phpunit && \
            ./install-composer.sh && \
            rm install-composer.sh && \
            php composer.phar require nikic/php-parser && \
            ln -s /opt/php/vendor/bin/php-parse /usr/local/bin/php-parse && \
            apk add bash && \
            wget -O phpab https://github.com/theseer/Autoload/releases/download/1.25.0/phpab-1.25.0.phar && \
            chmod +x phpab && \
            mv phpab /usr/local/bin/phpab

# ---

# CHEAT SHEET

# Install PHP Autoload Builder
  # RUN wget -O phpab https://github.com/theseer/Autoload/releases/download/1.25.0/phpab-1.25.0.phar
  # RUN chmod +x phpab
  # RUN mv phpab /usr/local/bin/phpab

# Generate autoload.php for multiple files
  # phpab --output src/autoload.php src
  # phpunit --bootstrap src/autoload.php tests/EmailTest
