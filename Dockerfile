#########################################################################################################################################################################################
###                                                                                                                                                                                   ###
###   [Build]                                                                                                                                                                         ###  
###   docker build -t scadiot-api-dev -f Dockerfile.dev .                                                                                                                             ###
###                                                                                                                                                                                   ###
###   [Win:Run]                                                                                                                                                                       ###
###   docker run -d -p 8080:8080 -v C:\Projects\scadiot\scadiot-api:/var/www/html --restart unless-stopped --network scadiot --name scadiot-api-dev scadiot-api-dev                   ###
###                                                                                                                                                                                   ###
###   [Mac:Run]                                                                                                                                                                       ###
###   docker run -d -p 8080:8080 -v /Users/ekoseoglu/Projects/scadiot/scadiot-api:/var/www/html --restart unless-stopped --network scadiot --name scadiot-api-dev scadiot-api-dev     ###
###                                                                                                                                                                                   ###
#########################################################################################################################################################################################

ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="Esat Köseoglu <e.koseoglu@logirit.com>"
LABEL Description="Lightweight container with Nginx 1.22 & PHP 8.2 based on Alpine Linux."

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  php82 \
  php82-ctype \
  php82-curl \
  php82-dom \
  php82-fpm \
  php82-gd \
  php82-intl \
  php82-mysqli \
  php82-opcache \
  php82-openssl \
  php82-phar \
  php82-session \
  php82-xml \
  php82-xmlreader \
  php82-json \
  php82-zlib \
  php82-bcmath \
  php82-common \
  php82-dba \
  php82-pecl-xdebug \
  php82-gd \
  php82-gmp \
  php82-imap \
  php82-ldap \
  php82-mbstring \
  php82-odbc \
  php82-pdo \
  php82-pdo_pgsql \
  php82-pdo_dblib \
  php82-pdo_odbc \
  php82-pdo_mysql \
  php82-pgsql \
  php82-snmp \
  php82-tidy \
  php82-simplexml \
  php82-tokenizer \
  php82-exif \
  php82-fileinfo \
  composer \
  supervisor

# Configure nginx - http
COPY docker/dev/config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY docker/dev/config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY docker/dev/config/fpm-pool.conf /etc/php82/php-fpm.d/www.conf
COPY docker/dev/config/php.ini /etc/php82/conf.d/custom.ini
COPY docker/dev/config/00_xdebug.ini /etc/php82/conf.d/00_xdebug.ini

# Configure supervisord
COPY docker/dev/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Setup document root
WORKDIR /var/www/html

# Add application
COPY --chown=nobody composer.json /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
