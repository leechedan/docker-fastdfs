#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	set -- tail -f /usr/local/nginx/logs/*.log  "$@"
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

mkdir -p /var/local/fdfs/storage/data 
mkdir -p /var/local/fdfs/tracker; 
sed -i 's/listen .*$/listen '"$WEB_PORT"';/g' ${NGINX_CONFIG_FILE}; 
sed -i 's/http.server_port=.*$/http.server_port='"$WEB_PORT"'/g' /etc/fdfs/storage.conf;
if [ "$IP" ]; then 
    IP=$(_ip_address)
fi 
echo ".."
if [ ! -f "${NGINX_CONFIG_FILE}" ]; then 
    cp -fr ${NGINX_PREFIX}/conf-bak/* ${NGINX_PREFIX}/conf; 
fi 
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$FDFS_PORT"'/g' /etc/fdfs/client.conf; 
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$FDFS_PORT"'/g' /etc/fdfs/storage.conf; 
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$FDFS_PORT"'/g' /etc/fdfs/mod_fastdfs.conf;
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start 
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start 
${NGINX_SBIN} -c /usr/local/nginx/conf/nginx.conf;


exec "$@"