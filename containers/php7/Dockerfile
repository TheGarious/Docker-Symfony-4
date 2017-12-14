FROM php:7.0-fpm

MAINTAINER Maxime GASTALDO <maxtor3569@gmail.com>

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        nano wget curl sudo git unzip bash-completion build-essential mysql-client \
        stunnel \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) mbstring \
    && docker-php-ext-install -j$(nproc) json \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-enable opcache \ 
    && pecl install apcu \ 
    && docker-php-ext-enable apcu

COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php.ini /usr/local/etc/php/

ENV TERM=xterm

WORKDIR /home/dev/

############
# Composer #
############

RUN curl -sS https://getcomposer.org/installer | php \
    && mv -v composer.phar /usr/local/bin/composer

########
# Node #
########

RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh \
    && chmod +x nodesource_setup.sh \
    && sudo bash nodesource_setup.sh \
    && apt-get install -y --force-yes -q nodejs \
    && apt-get -y -q autoclean \
    && apt-get -y -q autoremove \
    && rm nodesource_setup.sh

########
# User #
########

RUN mkdir -p /home/dev \
    && useradd -ms /bin/bash dev \
    && sudo adduser dev sudo \
    && sed -i -e 's/sudo	ALL=(ALL:ALL) ALL/sudo  ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers \
    && ln -s /home/dev/.docker_container/.bash_history /home/dev/.bash_history

ADD ./bashrc /home/dev/.bashrc

RUN chown dev:dev /home/dev \
	&& chown dev:dev /home/dev/.bashrc

###########
# STunnel #
###########

ADD stunnel.conf /etc/stunnel/stunnel.conf
ADD stunnel4 /etc/default/stunnel4

EXPOSE 8888
EXPOSE 8443

