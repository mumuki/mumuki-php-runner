FROM ubuntu:18.04
MAINTAINER Rodrigo Alfonso

# Install repositories
RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y

# Install tzdata (non-interactive)
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Install PHP 7.1
RUN apt-get install -y php7.1
RUN apt-get install -y php7.1-xml
RUN apt-get install -y php7.1-mbstring

# Install wget
RUN apt-get install -y wget

# Install PHP Autoload Builder
RUN wget -O phpab https://github.com/theseer/Autoload/releases/download/1.25.0/phpab-1.25.0.phar
RUN chmod +x phpab
RUN mv phpab /usr/local/bin/phpab

# Install PHPUnit 7
RUN wget -O phpunit https://phar.phpunit.de/phpunit-7.phar
RUN chmod +x phpunit
RUN mv phpunit /usr/local/bin/phpunit

# CHEAT SHEET (for multiple files)
# phpab --output src/autoload.php src
# phpunit --bootstrap src/autoload.php tests/EmailTest
