#!/usr/bin/env sh
set -eu
if [ "true" == "$DELETE_DATA_INIT_FLAG" ]; then
 rm -rf /home/yuqing/fastdfs/storage/data/.data_init_flag
fi

envsubst '${LUA_RESOLVER} ${CACHE_DIR} ${PORT} ${STORAGE_PROXY} ${FASTDFS_TRACKER_IP} ${FASTDFS_TRACKER_PORT}' \
    < /usr/local/openresty/nginx/conf/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf
mkdir -p ${CACHE_DIR}
exec "$@"
