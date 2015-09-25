# Humhub on Turnkeylinux

FROM cboulanger/turnkeylinux-lamp
MAINTAINER Christian Boulanger "info@bibliograph.org"

ENV DEBIAN_FRONTEND noninteractive

# Updates & packages install

RUN apt-get install -y -q php5-gd php5-curl php5-sqlite php5-ldap php-apc wget unzip cron

ENV HUMHUB_VERSION 0.11.2
ENV HUMHUB_GITHUB_TAG v$HUMHUB_VERSION
ENV HUMHUB_ZIP_DIR_NAME humhub-$HUMHUB_VERSION

RUN rm -rf /var/www/*
RUN wget -q https://github.com/humhub/humhub/archive/$HUMHUB_GITHUB_TAG.zip
RUN unzip -qq $HUMHUB_GITHUB_TAG.zip
RUN mv $HUMHUB_ZIP_DIR_NAME /var/www/humhub
RUN chown www-data:www-data -R /var/www/

# Apache config

ADD pre-conf.sh /pre-conf.sh
RUN chmod 750 /pre-conf.sh
RUN (/bin/bash -c /pre-conf.sh)
RUN service apache2 stop
RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2dismod status
RUN a2dissite default
RUN a2dissite default-ssl
RUN a2dissite phpmyadmin

ADD humhub-ssl.conf /etc/apache2/sites-available/humhub-ssl.conf
RUN a2ensite humhub-ssl.conf

# Import existing data for importing (optional)

ADD humhub-data /humhub-data
ADD import.sh /import.sh
RUN chmod 750 /import.sh
RUN (/bin/bash -c /import.sh)

# Add export script for migrating data to a different container

ADD export.sh /export.sh
RUN chmod 750 /export.sh

# Supervisor

ADD supervisor-humhub.conf /etc/supervisor/conf.d/supervisor-humhub.conf
