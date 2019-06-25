FROM alpine:3.9

ADD ./entrypoint.sh /entrypoint.sh
ENV FASTDFS_PATH=/opt/fdfs \
    NGINX_VERSION=1.15.0\
    HOME="/opt/fdfs" \
    WEB_PORT=80 \
    FDFS_PORT=22122 \
    FDFS_VERSION=5.11 \
    NGINX_CONFIG_FILE="/usr/local/nginx/conf/nginx.conf" \
    NGINX_PREFIX="/usr/local/nginx"
#get all the dependence& se/fdfgs
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps git gcc libc-dev make wget perl bash pcre-dev zlib-dev curl libgd gd-dev geoip-dev  freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
    && mkdir -p ${FASTDFS_PATH} \
    && curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.36.tar.gz -o fastcommon.tar.gz \
    && curl -fSL https://github.com/happyfish100/fastdfs/archive/V5.11.tar.gz -o fastdfs.tar.gz \
    && curl -fSL https://github.com/quentinyy/resource/raw/master/nginx-1.15.0.tar.gz -o nginx.tar.gz \
    && tar -zxvf nginx.tar.gz -C ${FASTDFS_PATH}\
    && tar -zxvf fastcommon.tar.gz -C ${FASTDFS_PATH}\
    && tar -zxvf fastdfs.tar.gz -C ${FASTDFS_PATH} \
    && cd ${FASTDFS_PATH}/libfastcommon-1.0.36/ \
    && ./make.sh \
    && ./make.sh install  \
    && cd ${FASTDFS_PATH}/fastdfs-5.11 && ./make.sh && ./make.sh install \
    && cd ${FASTDFS_PATH} && git clone http://192.168.122.10:31330/lijianchao/fastdfs-nginx-module.git fastdfs-nginx-module \
    && cd ${FASTDFS_PATH}/nginx-1.15.0 && ./configure --add-module=${FASTDFS_PATH}/fastdfs-nginx-module/src --with-http_image_filter_module=dynamic \
    && make -s \
    && make install -s \
    && cd /etc/fdfs/ \
        && cp storage.conf.sample storage.conf \
        && cp tracker.conf.sample tracker.conf \
        && cp client.conf.sample client.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
        #&/fdfs/storage|g" /etc/fdfs/client.conf  \

# 设置nginx和fastdfs联合环境，并配置nginx
        && cp ${FASTDFS_PATH}/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/ \
        && sed -i "s|^store_path0.*$|store_path0=/var/local/fdfs/storage|g" /etc/fdfs/mod_fastdfs.conf \
        && sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
        && cd ${FASTDFS_PATH}/fastdfs-${FDFS_VERSION}/conf/ \
        && cp http.conf mime.types anti-steal.jpg /etc/fdfs/ \
    && mkdir -p ${NGINX_PREFIX}/logs \
    && mkdir -p ${NGINX_PREFIX}/conf-bak \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /var/local/fdfs/tracker \
    && mkdir -p /var/local/fdfs/storage/data \
    && cd /var/local/fdfs/storage/data/ \
    && ln -s .. /var/local/fdfs/storage/data/M00 \
    && cp -r ${NGINX_PREFIX}/conf/* ${NGINX_PREFIX}/conf-bak \
    && chmod u+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"] 
