FROM alpine:3.6

MAINTAINER leechedan <leechedan@gmail.com>

ENV HOME=/root \
  PCRE_VERSION=8.42 \
  ZLIB_VERSION=1.2.11 \
  OPENSSL_VERSION=1_0_2o \
  NGINX_CT_VERSION=1.3.2 \
  NGINX_VERSION=1.13.12 \
  NGINX_PREFIX="/usr/local/nginx" \
  VAR_PREFIX="/var/nginx" \
  NGINX_MODULES_DIR="/usr/lib/nginx/modules" \
  NGINX_CONFIG_FILE="/usr/local/nginx/conf/nginx.conf" \
  NGINX_SBIN="/usr/sbin/nginx" \
  GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 


RUN \
  export CONFIG="  --prefix=${NGINX_PREFIX} \
        --sbin-path=${NGINX_SBIN} \
        --modules-path=${NGINX_MODULES_DIR} \
        --conf-path=${NGINX_CONFIG_FILE} \
        --error-log-path=${NGINX_PREFIX}/logs/error.log \
        --http-log-path=${NGINX_PREFIX}/logs/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-pcre-jit \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-http_v2_module \
        --with-pcre=${HOME}/pcre-$PCRE_VERSION \
        --with-zlib=${HOME}/zlib-$ZLIB_VERSION \
        --with-openssl=${HOME}/openssl-OpenSSL_$OPENSSL_VERSION \
        --add-module=${HOME}/nginx-ct-$NGINX_CT_VERSION \
        --add-module=${HOME}/fastdfs-nginx-module-1.20/src \
        --add-module=${HOME}/ngx_http_google_filter_module \
        --add-module=${HOME}/ngx_http_substitutions_filter_module \
    " && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories    \
    && apk add --update --no-cache --virtual .build-deps \
	make  libtool g++ autoconf automake  git\
	linux-headers \
	curl \
	libc-dev \
	libxslt-dev \
	openssl-dev \
	perl-dev ffmpeg-dev \
	bash   patch  build-base libc-dev openssl-dev pcre-dev zlib-dev linux-headers gnupg libxslt-dev gd-dev geoip-dev  freetype-dev libpng-dev libjpeg-turbo-dev \
    lua-dev xz-dev bzip2-dev \
	&& apk add --no-cache \
        gd \
		libgd \
		perl \
        pcre \
        geoip \
        libgcc \
        libxslt \
        zlib tzdata  ffmpeg graphicsmagick  freetype libpng libjpeg-turbo \
	&& apk  add --no-cache --virtual .nginx-rundeps \
	    so:libGeoIP.so.1 \
        so:libc.musl-x86_64.so.1 \
        so:libexslt.so.0 \
        so:libgd.so.3 \
        so:liblua.so.5 \
        so:libpcre.so.1 \
        so:libperl.so \
        so:libxml2.so.2 \
        so:libxslt.so.1 \
        so:libz.so.1 \
        && cd ${HOME} \
        && curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.36.tar.gz -o fastcommon.tar.gz \
        && curl -fSL  https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11 -o fastfs.tar.gz \
        && curl -fSL  https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.20.tar.gz -o fastdfs-nginx-module.tar.gz \
        && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.tar.gz -o pcre.tar.gz \
        && curl -fSL https://zlib.net/zlib-$ZLIB_VERSION.tar.gz -o zlib.tar.gz \
        && curl -fSL https://github.com/openssl/openssl/archive/OpenSSL_$OPENSSL_VERSION.tar.gz -o openssl.tar.gz \
        && curl -fSL https://github.com/grahamedgecombe/nginx-ct/archive/v$NGINX_CT_VERSION.tar.gz -o nginx-ct.tar.gz \
        && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
        && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
        && git clone https://github.com/cloudflare/sslconfig.git \
        && git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git \
        && git clone https://github.com/cuber/ngx_http_google_filter_module.git \
        && git clone https://github.com/azurewang/lua-resty-fastdfs \
        && git clone https://github.com/leafo/magick \
        && git clone https://github.com/clementfarabet/graphicsmagick \
        && tar zxf fastcommon.tar.gz \
        && tar zxf fastfs.tar.gz \
        && tar zxf fastdfs-nginx-module.tar.gz \
        && cd ${HOME}/libfastcommon-1.0.36/ \
        && ./make.sh \
        && ./make.sh install \
    && cd ${HOME}/fastdfs-5.11/ \
    && ./make.sh \
    && ./make.sh install \
    && cd ${HOME} \
    && tar -zxf pcre.tar.gz \
    && tar -zxf zlib.tar.gz \
    && tar -zxf openssl.tar.gz \
    && tar -zxf nginx-ct.tar.gz \
    && tar -zxf nginx.tar.gz \
    && tar -zxf fastdfs-nginx-module.tar.gz \
    && ls -al ${HOME} && echo $CONFIG \
    && export GNUPGHOME="$(mktemp -d)" \
    && found=''; \
    for server in \
        ha.pool.sks-keyservers.net \
        hkp://keyserver.ubuntu.com:80 \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu \
    ; do \
        echo "Fetching GPG key $GPG_KEYS from $server"; \
        gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& echo "$GNUPGHOME" \
    && rm -rf  nginx.tar.gz.asc \
    && rm pcre.tar.gz \
    && rm zlib.tar.gz \
    && rm openssl.tar.gz \
    && rm nginx-ct.tar.gz \
    && rm nginx.tar.gz \
    && rm fastdfs-nginx-module.tar.gz \
    && cd ${HOME}/openssl-OpenSSL_$OPENSSL_VERSION \
    && patch -p1 < ${HOME}/sslconfig/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102j.patch \
	&& cp /usr/include/fastcommon/*.h /usr/include/fastdfs/ \
    && cd ${HOME}/nginx-$NGINX_VERSION \
    && ./configure $CONFIG && make -j$(getconf _NPROCESSORS_ONLN)  > con.log \
    && make install > make.log \ 
    && cd ${HOME}/nginx-$NGINX_VERSION \
    && rm -rf ${NGINX_PREFIX}/html/ \
    && mkdir -p ${NGINX_PREFIX}/html/ \
    && mkdir -p /srv/image_cache /srv/video_cache \
    && strip ${NGINX_SBIN}* \
    && strip ${NGINX_MODULES_DIR}/*.so \
    && rm -rf ${HOME}/pcre-$PCRE_VERSION \
    && rm -rf ${HOME}/zlib-$ZLIB_VERSION \
    && rm -rf ${HOME}/openssl-OpenSSL_$OPENSSL_VERSION \
    && rm -rf ${HOME}/nginx-ct-$NGINX_CT_VERSION \
    && rm -rf ${HOME}/ngx_http_google_filter_module \
    && rm -rf ${HOME}/ngx_http_substitutions_filter_module \
    && rm -rf ${HOME}/fastdfs-nginx-module \
    && rm -rf ${HOME}/nginx-$NGINX_VERSION \
    && rm -rf *.log 
ADD ./docker.sh /entrypoint.sh
RUN cd /etc/fdfs/ \
        && cp storage.conf.sample storage.conf \
        && cp tracker.conf.sample tracker.conf \
        && cp client.conf.sample client.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/storage.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/client.conf  \ 
        && cp ${HOME}/fastdfs-nginx-module-1.20/src/mod_fastdfs.conf /etc/fdfs/ \
        && sed -i "s|^store_path0.*$|store_path0=/home/yuqing/fastdfs|g" /etc/fdfs/mod_fastdfs.conf \
        && sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
        && cd ${HOME}/fastdfs-5.11/conf/ \
        && cp http.conf mime.types anti-steal.jpg /etc/fdfs/ \
    && rm -rf ${HOME}/* \
    && mkdir -p ${NGINX_PREFIX}/logs \
    && mkdir -p ${NGINX_PREFIX}/conf-bak \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && chmod +x /entrypoint.sh \
    && mkdir -p /home/yuqing/fastdfs/data \
    && cd /home/yuqing/fastdfs/data/ \
    && ln -s .. /home/yuqing/fastdfs/data/M00 \
	&& apk del .build-deps && apk add bash 
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
