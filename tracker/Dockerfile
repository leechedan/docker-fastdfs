FROM alpine:3.6

MAINTAINER leechedan <leechedan@gmail.com>

ENV HOME=/root \
  PCRE_VERSION=8.42 \
  ZLIB_VERSION=1.2.11 \
  OPENSSL_VERSION=1_0_2o \
  NGINX_CT_VERSION=1.3.2 \
  NGINX_VERSION=1.13.12

ADD ./entrypoint.sh /entrypoint.sh
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk add --update --virtual .build-deps bash gcc libc-dev make openssl-dev pcre perl zlib-dev linux-headers curl \
    && apk add pcre perl\
    && cd ${HOME} \
	&& curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.36.tar.gz -o fastcommon.tar.gz \
	&& curl -fSL  https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11 -o fastfs.tar.gz \
	&& curl -fSL  https://github.com/happyfish100/fastdfs-nginx-module/archive/master.tar.gz -o fastdfs-nginx-module.tar.gz \
	&& tar zxf fastcommon.tar.gz \
	&& tar zxf fastdfs-nginx-module.tar.gz \
	&& tar zxf fastfs.tar.gz \
    &&  cd ${HOME}/libfastcommon-1.0.36/ \
	&& ./make.sh \
	&& ./make.sh install \
    &&  GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \ 
    &&  cd ${HOME}/fastdfs-5.11/ \
    && ./make.sh \
    && ./make.sh install \
    &&  cd /etc/fdfs/ \
	&& cp storage.conf.sample storage.conf \
	&& cp tracker.conf.sample tracker.conf \
	&& cp client.conf.sample client.conf \
	&& sed -i "s|/home/fastdfs|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
	&& sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/storage.conf \
	&& sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/client.conf \
    && cp ${HOME}/fastdfs-nginx-module-master/src/mod_fastdfs.conf /etc/fdfs/ \
	&& sed -i "s|^store_path0.*$|store_path0=/var/local/fdfs/storage|g" /etc/fdfs/mod_fastdfs.conf \
	&& sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
	&& cd ${HOME}/fastdfs-5.11/conf/ \
	&& cp http.conf mime.types anti-steal.jpg /etc/fdfs/ \
    && rm -rf ${HOME}/* \
    && mkdir -p /var/local/fdfs/tracker \
    && mkdir -p /var/local/fdfs/storage/data \
    && cd /var/local/fdfs/storage/data/ \
    && ln -s .. /var/local/fdfs/storage/data/M00 \
    && apk del .build-deps && apk add bash \
    && chmod u+x /entrypoint.sh && mkdir -p /home/yuqing/fastdfs

ENTRYPOINT ["sh","-c", "/entrypoint.sh"]
