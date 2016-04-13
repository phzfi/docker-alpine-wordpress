# Lightweight PHP-FPM & Nginx Docker Image for WordPress
[![devgeniem/alpine-wordpress docker image](http://dockeri.co/image/devgeniem/alpine-wordpress)](https://registry.hub.docker.com/u/devgeniem/alpine-wordpress/)

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

This is maintained repository. We use this project in production and recommend this for your projects too. This container doesn't have mysql or email, you need to provide them from elsewhere. This can be other container or your host machine.

## Aren't you only supposed to run one process per container?
We think that docker container should be small set of processes which provide one service rather than one clumsy process. This container uses [s6-overlay](https://github.com/just-containers/s6-overlay) in order to run php-fpm and nginx together.

## Container layout
Mount your wordpress project into:
```
/data/code
```

Your project should define web root in:
```
/data/code/web
```
This is the place where nginx will serve requests. This is compatible with [bedrock layout](https://github.com/roots/bedrock).

## User permissions
You can use `WP_GID` and `WP_UID` env to change web user and group.

If these are not set container will look for owner:group from files mounted in `/data/code/web/`.

If these files are owned by root user or root group the container will automatically use 100:101 as permissions instead. This is so that we won't never run nginx and php-fpm as root.

## Cron jobs
You can place cron file in `/data/code/tasks.cron`. This is symlinked to crond and run as user `wordpress`.

For example:
```
# do daily/weekly/monthly maintenance
*       *       *       *       *       echo "test log from: $(whoami)..." >> /tmp/test.log
```

## Environment Variables

### Timezone
This sets timezone for the environment and php. See candidates here: http://php.net/manual/en/timezones.php
```
TZ     # Default: 'Europe/Helsinki'
```

### Development/Production

You can set different setup into container by changing `WP_ENV`. Using 'development' disables opcache and enables xdebug.
```
WP_ENV # Default: '' Options: development,production
```

If you want to use xdebug in remote you can set your ip address in `XDEBUG_REMOTE_HOST`.
```
XDEBUG_REMOTE_HOST # Default: ''
```

### Database variables (mysql/mariadb)

```
DB_NAME     # Default: ''
DB_PASSWORD # Default: ''
DB_USER     # Default: ''
DB_HOST     # Default: ''
DB_PORT     # Default: ''
```

Remember to set `DB_NAME`, `DB_PASSWORD` and `DB_USER` and use these variables in your wp-config.php. These are automatically added as envs in php context.

### Email variables

```
SMTP_HOST
```

This variable changes the host where container tries to send mail from. By default this is docker host `172.17.0.1`.

```
SMTP_PORT
```

This variable changes the port where container tries to connect in order to send mail. By default this is `25`.

```
SMTP_TLS
```

If this is provided use username in authenticating to mail server. Default: null
```
SMTP_USER
```

If this is provided use password in authenticating to mail server. Default: null
```
SMTP_PASSWORD
```

If this is `on` mail will use username/password authentication in connections to smtp server.
This will automatically activate if you use `SMTP_USER` and `SMTP_PASSWORD`. Default: `off`
```
SMTP_AUTH
```

See more about these variables in [msmtp docs](http://msmtp.sourceforge.net/doc/msmtp.html#Authentication).

## What's inside container:
### For running WordPress
- php7
- php-fpm7
- nginx
- wp-cli
- composer

### For testing WordPress (Or any web application)
- phantomjs
- ruby
- poltergeist
- rspec
- capybara

### Other
- ssh client
