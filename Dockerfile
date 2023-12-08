#Inspired from https://github.com/javanile-backup/lamp/blob/master/7.2/Dockerfile
FROM ubuntu:22.04
LABEL MAINTAINER="Alex <github@jumel.xyz>"
WORKDIR /var/www/html

## Environment
ENV HTML_PUBLIC=
ENV PHP_MEMORY_LIMIT=32M
ENV PHP_MAX_EXECUTION_TIME=30

## Extend PHP
RUN apt-get update \
 ## Bases packages
 && apt install -y apache2 php libapache2-mod-php php-curl php-gd php-intl php-json php-mbstring php-xml php-zip \
 ## Zip extension
 && apt-get install -y --no-install-recommends zlib1g-dev \
 && docker-php-ext-install zip \
 ## Imap extension
 #&& apt-get install -y --no-install-recommends libc-client-dev libkrb5-dev \
 #&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
 #&& docker-php-ext-install imap \
 ## Xsl extension
 && apt-get install -y --no-install-recommends libxslt-dev \
 && docker-php-ext-install xsl \
 ## Intl extension
 && apt-get install -y --no-install-recommends zlib1g-dev libicu-dev g++ \
 && docker-php-ext-configure intl \
 && docker-php-ext-install intl \
 ## Other extensions
 #&& docker-php-ext-install mysqli pdo pdo_mysql gettext \
 ## Clean-up
 && rm -rf /var/lib/apt/lists/*
COPY php.ini /usr/local/etc/php/php.ini

## Sendmail
##RUN apt-get update && apt-get install -y --no-install-recommends ssmtp \
## && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && rm -rf /var/lib/apt/lists/*

## Crontab
RUN apt-get update \
 && apt-get install -y --no-install-recommends cron rsyslog \
 && rm -rf /etc/cron.* /var/lib/apt/lists/*
COPY crontab /etc/cron.d/crontab

## Apache
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
 && mkdir /etc/apache2/ssl && mkdir /log && chown www-data:www-data /log
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
#COPY ssl/localhost.crt /etc/apache2/ssl/localhost.crt
#COPY ssl/localhost.pem /etc/apache2/ssl/localhost.pem
RUN a2enmod rewrite && a2enmod ssl

##################################################################################################
#  commenté, à vérifier
##################################################################################################
## Command-line utils
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
# && php composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet \
# && rm composer-setup.php
#RUN apt-get update && apt-get install -y --no-install-recommends gnupg \
# && curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh \
# && bash nodesource_setup.sh && apt-get install -y --no-install-recommends nodejs \
# && rm -rf /var/lib/apt/lists/*

## Clean-up
RUN apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

## Running
COPY foreground.sh /usr/local/bin/
CMD ["foreground.sh"]
