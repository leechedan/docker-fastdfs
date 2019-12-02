#!/usr/bin/env sh
set -eu

envsubst '${FASTDFS_TRACKER_IP} ${FASTDFS_TRACKER_PORT}' < /usr/local/openresty/nginx/conf/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf

exec "$@"
