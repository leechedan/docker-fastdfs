FROM alpine:3.6

MAINTAINER leechedan <leechedan@gmail.com>

ENV HOME=/root \
  PCRE_VERSION=8.42 \
  ZLIB_VERSION=1.2.11 \
  OPENSSL_VERSION=1_0_2o \
  DATA_PREFIX=/var/local/fdfs \
  URL_HAVE_GROUP_NAME=true \
  TRACKERD_IP=tracker \
  TRACKERD_PORT=22122

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --update --virtual .build-deps gcc libc-dev make openssl-dev pcre perl zlib-dev linux-headers curl \
    && apk add bash tzdata \
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
    && ./make.sh install && ls /etc/fdfs -al  \
    && cp ${HOME}/fastdfs-nginx-module-master/src/mod_fastdfs.conf /etc/fdfs/ \
    && cd ${HOME}/fastdfs-5.11/conf/ \
    && cp http.conf mime.types anti-steal.jpg /etc/fdfs/ \
    && rm -rf ${HOME}/* \
    && mkdir -p ${DATA_PREFIX}/tracker \
    && apk del .build-deps 

ADD ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh","-c", "/entrypoint.sh"]
