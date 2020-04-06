#### 环境变量介绍

##### video
* PORT=80 NGINX对外端口
* STORAGE_PROXY=storage STORAGE对外代理域名
* FASTDFS_TRACKER_IP=tracker traclker对外代理域名
* FASTDFS_TRACKER_PORT=22122 tracker对外代理端口22122
* CACHE_DIR=/tmp/cache/ 缓存目录
* LUA_RESOLVER=127.0.0.1 dns解析IP，参考k8s的dns的ip
* DELETE_DATA_INIT_FLAG=true storage重启之后由于IP改变会找寻src-server进行同步，如果是重启需要删除

##### ngx
* TRACKER_SERVER=tracker:22122 tracker服务器

##### storage
* TRACKERD_PORT:22122
* TRACKERD_IP:tracker
* WEB_PORT:80 代理访问端口
* DATA_PREFIX:/home/yuqing/fastdfs 默认数据访问目录

##### tracker
* DATA_PREFIX:/home/yuqing/fastdfs 默认数据访问目录
* URL_HAVA_GROUP_NAME：true

#### 容器介绍
* tracker 文件状态和信息跟踪
* storage 与tracker进行连接和信息同步
* storage-nginx 与storage成对运行。只代理当前storage的文件访问
* video 视频信息和图片裁剪的代理容器，与tracker和storage通过网络连接。并提供上传接口
 - 上传视频同时，将json信息同时用拓展的方式上传到fdfs
 - 缩略图目录根据保持原有结构，并单独设置目录，可定时清理。

#### meta.josn介绍
* duration: 单位秒，音频或视频时长
* size:单位Bytes，文件大小size
* width：宽度
* height：高度
* ext：源文件的拓展名
* md5：源文件md5

#### 图片链接地址对应关系
* 原图访问地址：```http://img.xxx.com/xx/001/001.jpg```
* 缩略图访问地址：```http://img.xxx.com/xx/001/001@100x100.jpg``` 即为宽100,高100
 - 裁剪方式： ```gm convert input.jpg -thumbnail "100x100^" -gravity center -extent 100x100 output.jpg```
 - 缩小后以中心点开始进行宽高裁剪
 - 图片meta: ```{"size":300139,"md5":"fa17a3859d6b21fcf040121a712cd459","ext":"jpg",width":100,"height":100}```

#### 图片链接地址对应关系
* 原视频访问地址：```http://img.xxx.com/xx/001/001.mp4```
* 视频首帧原图访问地址：```http://img.xxx.com/xx/001/001.mp4.jpg``` 
 - ```ffmpeg -v 0 -ss 1 -i " .. orgfilepath .. " -vframes 1 -f image2 -y " .. filepath```
* 视频首帧原缩略图访问地址：```http://img.xxx.com/xx/001/001.mp4@100x100.jpg``` 即为宽100,高100
 - 参考图片裁剪方式
* 视频信息访问方式：```http://img.xxx.com/xx/001/001-meta.json```
 - 视频meta: ```{"size":24234,"ext":"mp4","md5":"",width":100,"height":100,"duration":12}```
 - 音频meta: ```{"size":300139,"md5":"fa17a3859d6b21fcf040121a712cd459","ext":"mp3","duration":18,"bitrate":129770}```
 - 上传方式: ```storage:upload_slave_by_buff1(groupid,"-meta",metainfo,"json")```

#### 上传接口
* 接口返回: ```{"9a43f10ac4106517d0c0b7a5d96b0219.mp4":"group1/M00/00/00/rBMAB16KpLGEVcZmAAAAAD_ppbY787.mp4"}```
* 图片上传: ```curl -X POST http://server/fdfs/upload -F "file=@a.jpg" -H "Conetne-Type:image/jpeg"```
* 视频上传: ```curl -X POST http://server/fdfs/upload -F "file=@a.mp4" -H "Conetne-Type:video/mp4"```
* 音频上传: ```curl -X POST http://server/fdfs/upload -F "file=@a.amr" -H "Conetne-Type:audio/mp3"```
* 其它拓展上传: ```curl -X POST http://server/fdfs/upload -F "file=@a.log"```
 - 注意key值(file)并无关系，Content-Type需要适当设置image/*,audio/*,video/*,如果不设置为作为未知类型处理，生成的meta.json信息只有md5/size/ext，设置错误会可能会导致上传失败或者meta.json信息缺失.