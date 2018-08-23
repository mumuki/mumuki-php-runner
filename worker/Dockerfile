FROM php:7.1-alpine
MAINTAINER Rodrigo Alfonso

# Install PHPUnit 7
RUN wget -O phpunit https://phar.phpunit.de/phpunit-7.phar &&
            chmod +x phpunit                               &&
            mv phpunit /usr/local/bin/phpunit

# ---

# CHEAT SHEET (for future multiple files support):
# phpab --output src/autoload.php src
# phpunit --bootstrap src/autoload.php tests/EmailTest
#
# Install PHP Autoload Builder
# RUN wget -O phpab https://github.com/theseer/Autoload/releases/download/1.25.0/phpab-1.25.0.phar
# RUN chmod +x phpab
# RUN mv phpab /usr/local/bin/phpab
