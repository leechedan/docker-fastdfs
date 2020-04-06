FROM alpine:3.8

ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    FDFS_VERSION="5.11" \
    NGINX_VERSION="1.14.0" \
    TENGINE_VERSION="2.2.2" \
    PORT= \
    GROUP_NAME=group1 \
    TRACKER_SERVER=tracker:22122

RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories    \
    && apk update && apk add --update --virtual .build-deps libc-dev perl curl gcc make wget  pcre-dev openssl-dev  pcre openssl \
 && apk add --no-cache  dnsmasq pcre perl openssl tzdata \
 && mkdir -p ${FASTDFS_PATH} \
 && cd ${FASTDFS_PATH} \
 && curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.36.tar.gz |tar zx \
 && curl -fSL  https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11  |tar xz\
 && curl -fSL  https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.20.tar.gz  |tar xz\
 && cd ${FASTDFS_PATH}/libfastcommon-1.0.36 \
 && ./make.sh \
 && ./make.sh install \
 && cd ${FASTDFS_PATH}/fastdfs-${FDFS_VERSION} \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/fastdfs-${FDFS_VERSION} \
 && rm -rf ${FASTDFS_PATH}/libfastcommon-1.0.36 \
 && mv ${FASTDFS_PATH}/fastdfs-nginx-module-1.20 ${FASTDFS_PATH}/fastdfs-nginx-module \
 && sed -i  's|include|include /usr/include/fastdfs /usr/include/fastcommon/|g'  ${FASTDFS_PATH}/fastdfs-nginx-module/src/config \ 
 && cd ${FASTDFS_PATH} && cat fastdfs-nginx-module/src/config \
 && wget http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz \
 && tar -zxf tengine-${TENGINE_VERSION}.tar.gz \
 && cd tengine-${TENGINE_VERSION} \
 && ./configure --prefix=/usr/local/nginx --add-module=${FASTDFS_PATH}/fastdfs-nginx-module/src/ \
 && make \
 && make install > log \
 && ln -s /usr/local/nginx/sbin/nginx /usr/bin/ \
 && rm -rf ${FASTDFS_PATH}/fastdfs-nginx-module && apk del .build-deps

COPY conf/* /etc/fdfs/
COPY conf/nginx-storage.conf /usr/local/nginx/conf
COPY start.sh /usr/bin/start.sh
ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]
