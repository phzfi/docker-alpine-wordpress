# Lightweight WordPress PHP-FPM & Nginx Docker Image
This is maintained repository. We use this project in production and recommend this for your projects too.

## Aren't you only supposed to run one process per container?
We think that docker container should be small set of processes which provide one service rather than one clumsy process. This container uses [s6-overlay](https://github.com/just-containers/s6-overlay) in order to run php-fpm and nginx together.

## This container includes:
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
