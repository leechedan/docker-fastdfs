#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	set -- tail -f ${DATA_PREFIX}/logs/trackerd.log  "$@"
#        set -- tail -f /home/yuqing/fastdfs/logs/trackerd.log "$@"
fi


_ip_address() {
	# scrape the first non-localhost IP address of the container
	# in Swarm Mode, we often get two IPs -- the container IP, and the (shared) VIP, and the container IP should always be first
	ip address | awk '
		$1 == "inet" && $NF != "lo" {
			gsub(/\/.+$/, "", $2)
			print $2
			exit
		}
	'
}

cd /etc/fdfs/ \
    && cp tracker.conf.sample tracker.conf \
    && cp client.conf.sample client.conf \
    && sed -i 's|^base_path.*$|base_path='"$DATA_PREFIX"'|g' /etc/fdfs/tracker.conf \
    && sed -i 's|^base_path.*$|base_path='"$DATA_PREFIX"'|g' /etc/fdfs/mod_fastdfs.conf \
    && sed -i 's|^store_path0.*$|store_path0='"$DATA_PREFIX"'/storage|g' /etc/fdfs/mod_fastdfs.conf \
    && sed -i 's|^url_have_group_name =.*$|url_have_group_name = '"$URL_HAVE_GROUP_NAME"'|g' /etc/fdfs/mod_fastdfs.conf
if [ ! "$IP" ]; then 
    IP=$(_ip_address)
fi 
mkdir -p ${DATA_PREFIX}

/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start 
exec "$@"
