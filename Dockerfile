ARG PHP_VERSION='7.2.9'
FROM php:${PHP_VERSION}-apache
LABEL maintainer = "fabio@naoimporta.com"

COPY files/mtcorsva.ttf /usr/share/fonts/truetype
COPY files/application.conf /etc/apache2/sites-available

RUN echo "deb http://http.us.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list.d/contrib.list \
  && apt update -y \
  && mkdir /usr/share/man/man1/ \
  && mkdir /usr/share/man/man7/ \
  && apt install -y ttf-dejavu ttf-mscorefonts-installer openjdk-8-jdk libldap2-dev libssl-dev libxml2-dev libpq-dev \
  && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
  && docker-php-ext-install ldap \
  && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
  && docker-php-ext-install pdo pdo_pgsql pgsql \
  && docker-php-ext-install mbstring \
  && docker-php-ext-install xml \
  && docker-php-ext-install tokenizer \
  && docker-php-ext-enable ldap pdo_pgsql mbstring xml tokenizer  \
  && curl https://raw.githubusercontent.com/php/php-src/PHP-${PHP_VERSION}/php.ini-development -o /usr/local/etc/php/php.ini \
  && sed -i 's|^post_max_size =.*|post_max_size = 100M|' /usr/local/etc/php/php.ini \
  && sed -i 's|^upload_max_filesize =.*|upload_max_filesize = 100M|' /usr/local/etc/php/php.ini \
  && sed -i 's|^default_charset =.*|default_charset = "UTF-8"|' /usr/local/etc/php/php.ini \
  && sed -i 's|^error_reporting =.*|error_reporting = E_ALL|' /usr/local/etc/php/php.ini \
  && sed -i 's|^display_errors =.*|display_errors = On|' /usr/local/etc/php/php.ini \
  && sed -i 's|^display_startup_errors =.*|display_startup_errors = On|' /usr/local/etc/php/php.ini \
  && fc-cache -fv \
  && a2ensite application && a2dissite 000-default default-ssl && a2enmod rewrite \
  && apt clean && rm -rf /var/lib/apt/lists

COPY files/times.jar files/font-monotype-corsiva.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/
COPY application /var/www/html/application

RUN chmod 777 /var/www/html/application/storage /var/www/html/application/bootstrap -R

EXPOSE 22/tcp 80/tcp 443/tcp
