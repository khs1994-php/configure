#！/bin/bash

export PHP_VERSION=7.0.0

set -e

# 1. download

if ! [ -d /usr/local/src/php-${PHP_VERSION} ];then

echo -e "Download php src ...\n\n"

cd /usr/local/src

sudo chmod -R 777 /usr/local/src

wget http://cn2.php.net/distributions/php-${PHP_VERSION}.tar.gz

tar -zxvf php-${PHP_VERSION}.tar.gz > /dev/null 2>&1

fi

cd /usr/local/src/php-${PHP_VERSION}

# 2. install packages

sudo apt install -y autoconf \
                   dpkg-dev \
                   file \
                   libc6-dev \
                   make \
                   pkg-config \
                   re2c \
                   gcc g++ \
                   libedit-dev \
                   zlib1g-dev \
                   libxml2-dev \
                   libssl-dev \
                   libsqlite3-dev \
                   libxslt1-dev \
                   libcurl4-openssl-dev \
                   libpq-dev \
                   libmemcached-dev \
                   libsasl2-dev \
                   libfreetype6-dev \
                   libpng-dev \
                   libjpeg-dev

# 3. bug

debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"
# https://bugs.php.net/bug.php?id=74125
if [ ! -d /usr/include/curl ]; then
    sudo ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl
fi

# 4. configure

./configure --prefix=/usr/local/php56 \
    --with-config-file-path=/usr/local/php56/etc \
    --with-config-file-scan-dir=/usr/local/php56/etc/conf.d \
    --disable-cgi \
    --enable-fpm \
    --with-fpm-user=nginx \
    --with-fpm-group=nginx \
    --with-curl \
    --with-gd \
    --with-gettext \
    --with-iconv-dir \
    --with-kerberos \
    --with-libedit \
    --with-openssl \
    --with-pcre-regex \
    --with-pdo-mysql \
    --with-pdo-pgsql \
    --with-xsl \
    --with-zlib \
    --with-mhash \
    --with-png-dir=/usr/lib \
    --with-jpeg-dir=/usr/lib\
    --with-freetype-dir=/usr/lib \
    --enable-ftp \
    --enable-mysqlnd \
    --enable-bcmath \
    --enable-libxml \
    --enable-inline-optimization \
    --enable-gd-jis-conv \
    --enable-mbregex \
    --enable-mbstring \
    --enable-pcntl \
    --enable-shmop \
    --enable-soap \
    --enable-sockets \
    --enable-sysvsem \
    --enable-xml \
    --enable-zip \
    --enable-calendar \
    --enable-intl \
    --enable-exif

# 5. make

make

# 6. make install

sudo make install

# 7. install extension

export PHP_ROOT=/usr/local/php70

${PHP_ROOT}/bin/php -v

sudo cp /usr/local/src/php-${PHP_VERSION}/php.ini-development ${PHP_ROOT}/etc/php.ini

sudo cp ${PHP_ROOT}/etc/php-fpm.d/www.conf.default ${PHP_ROOT}/etc/php-fpm.d/www.conf

sudo ${PHP_ROOT}/bin/pear config-set php_ini ${PHP_ROOT}/etc/php.ini
sudo ${PHP_ROOT}/bin/pecl config-set php_ini ${PHP_ROOT}/etc/php.ini

sudo ${PHP_ROOT}/bin/pecl update-channels

sudo ${PHP_ROOT}/bin/perl config-show
sudo ${PHP_ROOT}/bin/pecl config-show

sudo ${PHP_ROOT}/bin/pecl install igbinary \
                              redis \
                              memcached \
                              xdebug \
                              mongodb \
                              yaml

# 8. enable extension

echo "zend_extension=opcache" > ${PHP_ROOT}/etc/conf.d/extension-opcache.ini
