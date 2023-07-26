#!/bin/bash

# Define version numbers in arrays
openssl_version="3.1.1"
nginx_version="1.25.1"
rtmp_module_version="1.2.2"
pcre_version="8.45"
zlib_version="1.2.13"

# Update and install required packages
sudo apt update && sudo apt upgrade -y
sudo apt-get -y install software-properties-common build-essential git zlib1g-dev libpcre3 libpcre3-dev libbz2-dev libssl-dev libgd-dev libxslt-dev libgeoip-dev tar unzip curl

# Change directory to /root
cd /root

# Create the xc_nginx directory and navigate into it
mkdir xc_nginx
cd xc_nginx

# Download required source files
wget "https://www.openssl.org/source/openssl-$openssl_version.tar.gz"
tar -xzvf "openssl-$openssl_version.tar.gz"

wget "https://nginx.org/download/nginx-$nginx_version.tar.gz"
tar -xzvf "nginx-$nginx_version.tar.gz"

wget "https://sourceforge.net/projects/pcre/files/pcre/$pcre_version/pcre-$pcre_version.tar.gz/download" -O "pcre-$pcre_version.tar.gz"
tar -xzvf "pcre-$pcre_version.tar.gz"

wget "https://zlib.net/zlib-$zlib_version.tar.gz"
tar -xzvf "zlib-$zlib_version.tar.gz"

wget https://github.com/arut/nginx-rtmp-module/archive/refs/tags/v$rtmp_module_version.tar.gz
tar -xzvf "v$rtmp_module_version.tar.gz"

# Install libmaxminddb-dev
sudo add-apt-repository ppa:maxmind/ppa -y
sudo apt-get update
sudo apt-get install -y libmaxminddb-dev

# Clone ngx_http_geoip2_module repository
git clone https://github.com/leev/ngx_http_geoip2_module.git

# Configure and compile nginx
cd "nginx-$nginx_version"
make clean

./configure --prefix=/home/xtreamcodes/iptv_xtream_codes/nginx/ \
            --http-client-body-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/client_temp \
            --http-proxy-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/proxy_temp \
            --http-fastcgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/fastcgi_temp \
            --lock-path=/home/xtreamcodes/iptv_xtream_codes/tmp/nginx.lock \
            --http-uwsgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/uwsgi_temp \
            --http-scgi-temp-path=/home/xtreamcodes/iptv_xtream_codes/tmp/scgi_temp \
            --conf-path=/home/xtreamcodes/iptv_xtream_codes/nginx/conf/nginx.conf \
            --error-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/error.log \
            --http-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/access.log \
            --pid-path=/home/xtreamcodes/iptv_xtream_codes/nginx/nginx.pid \
            --with-http_ssl_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_v2_module \
            --with-ld-opt='-Wl,-z,relro -Wl,--as-needed -static' \
            --with-pcre="../pcre-$pcre_version" \
            --with-pcre-jit \
            --with-zlib="../zlib-$zlib_version" \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_stub_status_module \
            --with-http_auth_request_module \
            --with-threads \
            --with-mail \
            --with-mail_ssl_module \
            --with-file-aio \
            --with-cpu-opt=generic \
            --with-cc-opt='-static -static-libgcc -g -O2 -Wformat -Wall' \
            --add-module=../ngx_http_geoip2_module \
            --with-openssl="../openssl-$openssl_version"

make

# Install compiled nginx
sudo make install

# Go back to the nginx directory to compile nginx_rtmp
cd /root/nginx-$nginx_version
make clean

# Configure and compile nginx_rtmp
./configure --prefix=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/ \
            --lock-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/nginx_rtmp.lock \
            --conf-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/conf/nginx.conf \
            --error-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/rtmp_error.log \
            --http-log-path=/home/xtreamcodes/iptv_xtream_codes/logs/rtmp_access.log \
            --pid-path=/home/xtreamcodes/iptv_xtream_codes/nginx_rtmp/nginx.pid \
            --add-module=../nginx-rtmp-module-$rtmp_module_version \
            --with-ld-opt='-Wl,-z,relro -Wl,--as-needed -static' \
            --with-pcre \
            --without-http_rewrite_module \
            --with-file-aio \
            --with-cpu-opt=generic \
            --with-cc-opt='-static -static-libgcc -g -O2 -Wformat -Wall' \
            --with-openssl="../openssl-$openssl_version" \
            --add-module=../ngx_http_geoip2_module \
            --with-http_ssl_module
            --binary-name=nginx_rtmp  # Specify the binary name here


make

# Install compiled nginx_rtmp
sudo make install

# Rename the binary to nginx_rtmp
sudo mv /home/xtreamcodes/iptv_xtream_codes/nginx/sbin/nginx /home/xtreamcodes/iptv_xtream_codes/nginx/sbin/nginx_rtmp

echo "Nginx compilation and installation completed!"



