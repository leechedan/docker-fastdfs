FROM alpine:3.6

MAINTAINER leechedan <leechedan@gmail.com>

ENV HOME /root
ENV PCRE_VERSION 8.42
ENV ZLIB_VERSION 1.2.11
ENV OPENSSL_VERSION 1_0_2o
ENV NGINX_CT_VERSION 1.3.2
ENV NGINX_VERSION 1.13.12

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# 安装准备 --no-cache 
RUN    apk update 
RUN    apk add --virtual .build-deps bash gcc libc-dev make openssl-dev pcre perl zlib-dev linux-headers curl 
# 下载fastdfs、libfastcommon、nginx插件的源码
RUN     cd ${HOME} \
        && curl -fSL https://github.com/happyfish100/libfastcommon/archive/V1.0.36.tar.gz -o fastcommon.tar.gz \
        && curl -fSL  https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11 -o fastfs.tar.gz \
        && curl -fSL  https://github.com/happyfish100/fastdfs-nginx-module/archive/master.tar.gz -o fastdfs-nginx-module.tar.gz \
        && tar zxf fastcommon.tar.gz \
        && tar zxf fastdfs-nginx-module.tar.gz \
        && tar zxf fastfs.tar.gz

# 安装libfastcommon
RUN     cd ${HOME}/libfastcommon-1.0.36/ \
        && ./make.sh \
        && ./make.sh install

# 安装fastdfs v5.11
RUN   GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \ 
    &&  cd ${HOME}/fastdfs-5.11/ \
    && ./make.sh \
    && ./make.sh install 

# 配置fastdfs: base_dir
RUN     cd /etc/fdfs/ \
        && cp storage.conf.sample storage.conf \
        && cp tracker.conf.sample tracker.conf \
        && cp client.conf.sample client.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/storage.conf \
        && sed -i "s|/home/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/client.conf 

# 默认fastdfs端口
ENV FDFS_PORT 22122
# 设置nginx和fastdfs联合环境，并配置nginx
RUN     cp ${HOME}/fastdfs-nginx-module-master/src/mod_fastdfs.conf /etc/fdfs/ \
        && sed -i "s|^store_path0.*$|store_path0=/var/local/fdfs/storage|g" /etc/fdfs/mod_fastdfs.conf \
        && sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
        && cd ${HOME}/fastdfs-5.11/conf/ \
        && cp http.conf mime.types anti-steal.jpg /etc/fdfs/ 
# 清理文件
RUN rm -rf ${HOME}/* 

# 配置启动脚本，在启动时中根据环境变量替换nginx端口、fastdfs端口
# 默认nginx端口
RUN mkdir -p /var/local/fdfs/tracker \
    && mkdir -p /var/local/fdfs/storage/data \
    && cd /var/local/fdfs/storage/data/ \
    && ln -s .. /var/local/fdfs/storage/data/M00 
# 创建启动脚本

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

# 暴露端口。改为采用host网络，不需要单独暴露端口
# EXPOSE 80 22122

ENTRYPOINT ["/entrypoint.sh"]