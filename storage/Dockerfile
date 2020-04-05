FROM alpine:3.6

MAINTAINER leechedan <leechedan@gmail.com>

ENV HOME=/root \
  PCRE_VERSION=8.42 \
  ZLIB_VERSION=1.2.11 \
  DATA_PREFIX="/home/yuqing/fastdfs"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories    \
    && apk add --update --no-cache --virtual .build-deps \
	make  libtool g++ autoconf automake  git\
	linux-headers \
	curl \
	bash   patch  build-base  \
	&& apk add --no-cache \
	perl \
        pcre \
        libgcc \
        libxslt \
        zlib tzdata  \
        && cd ${HOME} \
        && curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.36.tar.gz -o fastcommon.tar.gz \
        && curl -fSL  https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11 -o fastfs.tar.gz \
        && tar zxf fastcommon.tar.gz \
        && tar zxf fastfs.tar.gz \
        && cd ${HOME}/libfastcommon-1.0.36/ \
        && ./make.sh \
        && ./make.sh install \
    && cd ${HOME}/fastdfs-5.11/ \
    && ./make.sh \
    && ./make.sh install \
    && cd ${HOME} \
    && ls -al ${HOME} && echo $CONFIG \
    && cd ${HOME}/fastdfs-5.11/conf/ \
    && cp http.conf mime.types anti-steal.jpg /etc/fdfs/ \
    && rm -rf ${HOME}/* \
    && mkdir -p ${DATA_PREFIX}/data \
    && cd ${DATA_PREFIX}/data/ \
    && ln -s .. ${DATA_PREFIX}/data/M00 \
	&& apk del .build-deps && apk add bash 
ADD ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
