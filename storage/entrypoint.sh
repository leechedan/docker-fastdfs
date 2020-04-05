#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
#	set -- nginx -g 'daemon off; error_log /var/log/error.log debug;'  "$@"
   set -- tail -f ${DATA_PREFIX}/logs/*.log
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

if [ ! "$TRACKERD_IP" ]; then 
    TRACKERD_IP=$(_ip_address)
fi 
cd /etc/fdfs/ \
        && cp storage.conf.sample storage.conf \
        && cp tracker.conf.sample tracker.conf \
        && cp client.conf.sample client.conf 
echo "fin"
mkdir -p /home/yuqing/fastdfs/
sed -i 's|^http.server_port=.*$|http.server_port='"$WEB_PORT"'|g' /etc/fdfs/storage.conf
sed -i 's|^tracker_server=.*$|tracker_server='"$TRACKERD_IP"':'"$TRACKERD_PORT"'|g' /etc/fdfs/client.conf
sed -i 's|^tracker_server=.*$|tracker_server='"$TRACKERD_IP"':'"$TRACKERD_PORT"'|g' /etc/fdfs/storage.conf 
sed -i 's|^store_path0=.*$|store_path0='"$DATA_PREFIX"'|g' /etc/fdfs/storage.conf
sed -i 's|^base_path=.*$|base_path='"$DATA_PREFIX"'|g' /etc/fdfs/storage.conf

/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start 
sleep 5
exec "$@"
