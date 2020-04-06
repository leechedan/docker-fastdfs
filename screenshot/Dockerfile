FROM openresty/openresty:1.13.6.2-2-centos
ADD luajit-ffi /tmp/luajit-ffi

RUN cd /tmp/ && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo \
	&& curl -fSL https://ffmpeg.org/releases/ffmpeg-4.1.tar.gz |tar zx \
	&& curl -fSL https://github.com/leafo/magick/archive/master.tar.gz |tar zx \
	&& curl -fSL https://github.com/azurewang/lua-resty-fastdfs/archive/master.tar.gz |tar zx \
	&& curl -fSL ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/1.3/GraphicsMagick-1.3.31.tar.gz -o GraphicsMagick.tar.gz \
	&& tar zxf GraphicsMagick.tar.gz \
	&& yum makecache \
    && yum install -y gcc dnsmasq \
                   gcc-c++ \
                   zlib \
                   zlib-devel \
                   openssl \
                   openssl-devel \
                   pcre pcre-devel \
                   bzip2  \
                   libpng \
                   libjpeg \
                   libpng-devel \
                   libjpeg-devel \
                   ghostscript \
                   libtiff \
                   libtiff-devel \
                   freetype \
                   freetype-devel \
                   ImageMagick \
                   ImageMagick-devel \
&& cd /tmp/GraphicsMagick-1.3.31 && \
    ./configure && \
    make && \
    make install && \
    cd /usr/lib64/ && \
    ln -sv liblzma.so.5 liblzma.so && \
    cd /tmp/ffmpeg-4.1 && \
    ./configure --enable-shared --disable-x86asm && \
    make && \
    make install && \
    echo "/usr/local/lib" >> /etc/ld.so.conf && \
    ldconfig && \
    cd /tmp/luajit-ffi && \
    chmod +x build.sh && \
    ./build.sh && \
    mv /tmp/luajit-ffi/libavmeta.so /usr/local/lib/ && \
    ldconfig /usr/local/lib && \
    cd /tmp/magick-master && \
    luarocks install magick && \
    cd /tmp && cp luajit-ffi/libavmeta.lua /usr/local/openresty/lualib/ && \
    cp -r lua-resty-fastdfs-master/lib/resty/fastdfs /usr/local/openresty/lualib/resty && \
    cp -r /tmp/magick-master /usr/local/openresty/lualib/ && \
    yum remove -y make gcc gcc-c++ && \
    yum clean all && \
    rm -rf /tmp/* 
    #yum -y remove $(rpm -qa "*-devel")
ENV PORT=80 \
    STORAGE_PROXY=storage \
    FASTDFS_TRACKER_IP=tracker \
    FASTDFS_TRACKER_PORT=22122 \
    CACHE_DIR=/tmp/cache/ \
    LUA_RESOLVER=127.0.0.1 \
    DELETE_DATA_INIT_FLAG=true
COPY nginx.conf.template /usr/local/openresty/nginx/conf/nginx.conf.template
COPY docker-entrypoint.sh /
COPY *.lua /usr/local/openresty/site/

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/openresty", "-g", "daemon off;"]
