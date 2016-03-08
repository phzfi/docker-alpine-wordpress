FROM alpine:edge
MAINTAINER Onni Hakala - Geniem Oy. <onni.hakala@geniem.com>

#php5.6
## Install php + nginx
#RUN apk update \
#    && apk add bash less vim nano git mysql-client nginx ca-certificates \
#    # PHP 5.6
#    php php-fpm php-json php-zlib php-xml php-pdo php-phar php-openssl \
#    php-pdo_mysql php-mysqli \
#    php-gd php-mcrypt \
#    php-curl php-opcache php-ctype  \
#    php-intl php-bcmath php-dom php-xmlreader php-apcu php-mysql php-iconv \
#    # Libs for php
#    libssh2 curl libpng freetype libjpeg-turbo libgcc libxml2 libstdc++ icu-libs libltdl libmcrypt \
#    && apk add -u musl

# Install php + nginx
RUN apk update \
    && apk add bash less vim nano git mysql-client nginx ca-certificates \
    # Libs for php
    libssh2 curl libpng freetype libjpeg-turbo libgcc libxml2 libstdc++ icu-libs libltdl libmcrypt \
    # For mails
    msmtp \
    && apk add -u musl

# php7 depracates following packages: php-apcu php-mysql php-iconv
# Install php 7
RUN apk add php7 php7-session php7-fpm php7-json php7-zlib php7-xml php7-pdo php7-phar php7-openssl \
    php7-pdo_mysql php7-mysqli php7-mysqlnd \
    php7-gd php7-mcrypt \
    php7-curl php7-opcache php7-ctype  \
    php7-intl php7-bcmath php7-dom php7-xmlreader --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ 

##
# Install PhantomJS
##

# Add preconfigured phantomjs package build with: https://github.com/fgrehm/docker-phantomjs2
# This adds all sorts of dependencies from dockerize magic
ADD lib/phantomjs-dependencies.tar.gz /

# Update phantomjs binary to 2.1.1
ADD https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp/
RUN cd /tmp && \
    tar -xjf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
    chmod +x /usr/local/bin/phantomjs && \
    rm -r /tmp/*

# Add S6-overlay to use S6 process manager
# https://github.com/just-containers/s6-overlay/#the-docker-way
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

# Small fixes
RUN ln -s /etc/php7 /etc/php && \
    ln -s /usr/bin/php7 /usr/bin/php && \
    ln -s /usr/sbin/php-fpm7 /usr/bin/php-fpm && \
    ln -s /usr/lib/php7 /usr/lib/php && \
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/php.ini && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd-

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
    # This is used by nginx and php-fpm
    WEB_ROOT="/data/code/web"\
    # This is used automatically by wp-cli
    WP_CORE="/data/code/web/wp"

# Remove cache and tmp files
RUN rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# Set default path to project mountpoint
WORKDIR /data/code

EXPOSE 80
VOLUME ["/data"]

ENTRYPOINT ["/init"]