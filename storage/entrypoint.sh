#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	set -- nginx -g 'daemon off; error_log /var/log/error.log debug;'  "$@"
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

sed -i 's/http.server_port=.*$/http.server_port='"$WEB_PORT"'/g' /etc/fdfs/storage.conf;
if [ ! "$IP" ]; then 
    IP=$(_ip_address)
fi 

mkdir -p /home/yuqing/fastdfs/
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$FDFS_PORT"'/g' /etc/fdfs/client.conf; 
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$FDFS_PORT"'/g' /etc/fdfs/storage.conf; 
sed -i 's/^store_path0=.*$/store_path0=\/home\/yuqing\/fastdfs/g' /etc/fdfs/storage.conf; 
sed -i 's/^base_path=.*$/base_path=\/home\/yuqing\/fastdfs/g' /etc/fdfs/storage.conf; 
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$FDFS_PORT"'/g' /etc/fdfs/mod_fastdfs.conf;

/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start 
sleep 5
exec "$@"
