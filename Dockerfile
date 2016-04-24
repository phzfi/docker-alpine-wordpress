FROM alpine:edge
MAINTAINER Onni Hakala - Geniem Oy. <onni.hakala@geniem.com>

# Install dependencies
RUN apk update && \
    apk add bash less vim nano git mysql-client nginx ca-certificates openssh-client \
    # Libs for php
    libssh2 curl libpng freetype libjpeg-turbo libgcc libxml2 libstdc++ icu-libs libltdl libmcrypt \
    # For mails
    msmtp \
    # Set timezone according your location
    tzdata \
    && apk add -u musl

# Install php 7
RUN apk add php7 php7-session php7-fpm php7-json php7-zlib php7-xml php7-pdo php7-phar php7-openssl \
    php7-pdo_mysql php7-mysqli php7-mysqlnd php7-mcrypt php7-xdebug \
    php7-gd php7-curl php7-opcache php7-ctype php7-mbstring php7-soap \
    php7-intl php7-bcmath php7-dom php7-xmlreader --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/

##
# Install ruby and integration testing tools
##
RUN apk add ruby ruby-nokogiri ruby-json build-base ruby-dev && \
    gem install rspec rspec-retry poltergeist capybara --no-ri --no-rdoc && \
    apk del build-base ruby-dev

##
# Install PhantomJS
##

# Add preconfigured phantomjs package build with: https://github.com/fgrehm/docker-phantomjs2
# This adds all sorts of dependencies from dockerize magic
ADD lib/phantomjs-dependencies.tar.gz /

# Add S6-overlay to use S6 process manager
# https://github.com/just-containers/s6-overlay/#the-docker-way
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

# Small fixes
RUN ln -s /etc/php7 /etc/php && \
    ln -s /usr/bin/php7 /usr/bin/php && \
    ln -s /usr/sbin/php-fpm7 /usr/bin/php-fpm && \
    ln -s /usr/lib/php7 /usr/lib/php && \
    # Remove nginx user because we will create a user with correct permissions dynamically
    deluser nginx

ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp-cli

# Install composer
# source: https://getcomposer.org/download/
ADD https://getcomposer.org/installer /tmp/composer-setup.php
RUN cd /tmp && \
    php composer-setup.php && \
    rm  composer-setup.php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +rx /usr/local/bin/composer && \
    chmod +rx /usr/local/bin/wp-cli

##
# Add Project files like nginx and php-fpm processes and configs
# ALso custom scripts and bashrc
##
ADD system-root/ /

ENV TERM="xterm" \
    DB_HOST="" \
    DB_PORT="" \
    DB_NAME="" \
    DB_USER=""\
    DB_PASSWORD=""\
    # This is for your project root
    PROJECT_ROOT="/data/code"\
    # This is used by nginx and php-fpm
    WEB_ROOT="/data/code/web"\
    # This is used automatically by wp-cli
    WP_CORE="/data/code/web/wp"\
    # This can be overidden by you, it's just default for us
    TZ="Europe/Helsinki"\
    # Update path with composer files
    PATH="$PATH:/data/code/vendor/.bin:/root/.composer/bin"

# Remove cache and tmp files
RUN rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# Set default path to project mountpoint
WORKDIR /data/code

EXPOSE 80

ENTRYPOINT ["/init"]
