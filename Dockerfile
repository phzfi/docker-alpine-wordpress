FROM devgeniem/alpine-php-base:1.0.3
MAINTAINER Onni Hakala - Geniem Oy. <onni.hakala@geniem.com>

##
# Add Project files like nginx and php-fpm processes and configs
# Also custom scripts and bashrc
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

# Set default path to project mountpoint
WORKDIR /data/code

EXPOSE 80

ENTRYPOINT ["/init"]
