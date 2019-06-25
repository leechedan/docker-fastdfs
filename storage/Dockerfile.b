FROM alpine:3.9

MAINTAINER leechedan <leechedan@gmail.com>

ENV HOME /usr/local
ENV PCRE_VERSION 8.42
ENV ZLIB_VERSION 1.2.11
ENV OPENSSL_VERSION 1_0_2o
ENV NGINX_CT_VERSION 1.3.2
ENV NGINX_VERSION 1.15.0

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 安装准备 --no-cache 
RUN    apk update &&  apk add --virtual .build-deps bash gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers curl gnupg libxslt-dev gd-dev geoip-dev  freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev  libtool g++ autoconf automake libgd \
        gnupg \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        git \
        patch \
        build-base \
        perl-dev \
# 下载fastdfs、libfastcommon、nginx插件的源码
        && cd ${HOME} \
        && curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.36.tar.gz -o fastcommon.tar.gz \
        && curl -fSL  https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11 -o fastfs.tar.gz \
        && curl -fSL  https://github.com/happyfish100/fastdfs-nginx-module/archive/master.tar.gz -o fastdfs-nginx-module.tar.gz \
        && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.tar.gz -o pcre.tar.gz \
        && curl -fSL https://zlib.net/zlib-$ZLIB_VERSION.tar.gz -o zlib.tar.gz \
        && curl -fSL https://github.com/openssl/openssl/archive/OpenSSL_$OPENSSL_VERSION.tar.gz -o openssl.tar.gz \
        && curl -fSL https://github.com/grahamedgecombe/nginx-ct/archive/v$NGINX_CT_VERSION.tar.gz -o nginx-ct.tar.gz \
        && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
        && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
        && git clone https://github.com/cloudflare/sslconfig.git \
        && tar zxf fastcommon.tar.gz \
        && tar zxf fastfs.tar.gz \
        && tar zxf fastdfs-nginx-module.tar.gz

# 安装libfastcommon
RUN     cd ${HOME}/libfastcommon-1.0.36/ \
        && ./make.sh \
        && ./make.sh install
ENV NGINX_MODULES_DIR="/usr/lib/nginx/modules" \
    NGINX_PREFIX="/usr/local/nginx" \
    NGINX_CONFIG_FILE="/usr/local/nginx/conf/nginx.conf" \
    NGINX_SBIN="/usr/sbin/nginx" \
    CONFIG="  --prefix=${NGINX_PREFIX} \
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
        --add-module=${HOME}/fastdfs-nginx-module-master/src \
    "

# 安装fastdfs v5.11
RUN   GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \ 
    &&  cd ${HOME}/fastdfs-5.11/ \
    && ./make.sh \
    && ./make.sh install \
    && cd ${HOME} \
    && tar -zxC ${HOME} -f pcre.tar.gz \
    && tar -zxC ${HOME} -f zlib.tar.gz \
    && tar -zxC ${HOME} -f openssl.tar.gz \
    && tar -zxC ${HOME} -f nginx.tar.gz \
    && tar -zxC ${HOME} -f fastdfs-nginx-module.tar.gz \
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
    && rm -r "$GNUPGHOME" nginx.tar.gz.asc \
    && rm pcre.tar.gz \
    && rm zlib.tar.gz \
    && rm openssl.tar.gz \
    && rm nginx.tar.gz \
    && rm fastdfs-nginx-module.tar.gz \
    && chmod u+x ${HOME}/fastdfs-nginx-module-master/src/config \
    && cd ${HOME}/openssl-OpenSSL_$OPENSSL_VERSION \
    && patch -p1 < ${HOME}/sslconfig/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102j.patch \
    &&  cp /usr/include/fastcommon/*.h /usr/include/fastdfs/ \
    &&  cd ${HOME}/nginx-$NGINX_VERSION \
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && cd ${HOME}/nginx-$NGINX_VERSION \
    && rm -rf ${NGINX_PREFIX}/html/ \
    && mkdir -p ${NGINX_PREFIX}/html/ \
    && install -m644 html/index.html ${NGINX_PREFIX}/html/ \
    && install -m644 conf/* ${NGINX_PREFIX}/conf/ \
    && install -m644 html/50x.html ${NGINX_PREFIX}/html/ \
    && install -m644 html/50x.html ${NGINX_PREFIX}/html/ \
    && ln -s ${NGINX_MODULES_DIR} ${NGINX_PREFIX}/modules \
    && strip ${NGINX_SBIN}* \
    && strip ${NGINX_MODULES_DIR}/*.so \
    && rm -rf ${HOME}/pcre-$PCRE_VERSION \
    && rm -rf ${HOME}/zlib-$ZLIB_VERSION \
    && rm -rf ${HOME}/openssl-OpenSSL_$OPENSSL_VERSION \
    && rm -rf ${HOME}/fastdfs-nginx-module \
    && rm -rf ${HOME}/nginx-$NGINX_VERSION \
    && rm -rf *.log


# 配置fastdfs: base_dir
RUN     cd /etc/fdfs/ \
        && cp storage.conf.sample storage.conf \
        && cp tracker.conf.sample tracker.conf \
        && cp client.conf.sample client.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/storage.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/client.conf 

ENV WEB_PORT 8088
# 默认fastdfs端口
ENV FDFS_PORT 22122
# 设置nginx和fastdfs联合环境，并配置nginx
RUN     cp ${HOME}/fastdfs-nginx-module-master/src/mod_fastdfs.conf /etc/fdfs/ \
        && sed -i "s|^store_path0.*$|store_path0=/var/local/fdfs/storage|g" /etc/fdfs/mod_fastdfs.conf \
        && sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
        && cd ${HOME}/fastdfs-5.11/conf/ \
        && cp http.conf mime.types anti-steal.jpg /etc/fdfs/ \
        && echo -e "\
events {\n\
    worker_connections  1024;\n\
}\n\

http {\n\
    include       mime.types;\n\
    default_type  application/octet-stream;\n\
    server {\n\
        listen 8888;\n\
        server_name localhost;\n\
        location  /group1/M00 {\n\
            ngx_fastdfs_module;\n\
        }\n\
    }\n\
}">${NGINX_CONFIG_FILE}

# 清理文件
RUN mkdir -p ${NGINX_PREFIX}/logs \
    && mkdir -p ${NGINX_PREFIX}/conf-bak \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx
#rm -rf ${HOME}/* \

# 配置启动脚本，在启动时中根据环境变量替换nginx端口、fastdfs端口
# 默认nginx端口
RUN mkdir -p /var/local/fdfs/tracker \
    && mkdir -p /var/local/fdfs/storage/data \
    && cd /var/local/fdfs/storage/data/ \
    && ln -s .. /var/local/fdfs/storage/data/M00 \
    && cp -r ${NGINX_PREFIX}/conf/* ${NGINX_PREFIX}/conf-bak 
# 创建启动脚本

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

# 暴露端口。改为采用host网络，不需要单独暴露端口
# EXPOSE 80 22122

ENTRYPOINT ["/entrypoint.sh"]
