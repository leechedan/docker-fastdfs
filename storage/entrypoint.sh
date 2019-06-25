#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	set -- tail -f /home/yuqing/fastdfs/logs/storaged.log  "$@"
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

# 配置启动脚本，在启动时中根据环境变量替换nginx端口、fastdfs端口
# 默认nginx端口

echo "define ip"
sed -i 's/http.server_port=.*$/http.server_port='"$WEB_PORT"'/g' /etc/fdfs/storage.conf;
if [ ! "$IP" ]; then 
    IP=$(_ip_address)
fi 
mkdir -p /home/yuqing/fastdfs/
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$TRACKER_SERVICE_PORT"'/g' /etc/fdfs/client.conf; 
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$TRACKER_SERVICE_PORT"'/g' /etc/fdfs/storage.conf; 
sed -i 's/^store_path0=.*$/store_path0=\/home\/yuqing\/fastdfs/g' /etc/fdfs/mod_fastdfs.conf; 
sed -i 's/^tracker_server=.*$/tracker_server='"$IP"':'"$TRACKER_SERVICE_PORT"'/g' /etc/fdfs/mod_fastdfs.conf;

rm -rf /home/yuqing/fastdfs/data/fdfs_storaged.pid
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start 
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf

exec "$@"
