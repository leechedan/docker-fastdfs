## 参考来源

```http
https://github.com/liufan1989/openresty-graphicsmagick-ffmpeg-fastdfs
```

## docker镜像

```shell
docker build -t nginx-opentry-fastdfs .
```

## 运行docker镜像

```shell
docker run -d --name=nginx-opentry-fastdfs -p 7777:7777 -e "FASTDFS_TRACKER_IP=xxxxxxxx" -e "FASTDFS_TRACKER_PORT=xxx" nginx-opentry-fastdfs
```

## Example

```
* upload file: http://127.0.0.1:7777/share/upload/  [http-form-data]
* upload file: curl -X POST http://localhost:9089/share/upload -F "video=@/home/docker/fdfs-v/abc.mp4" -H "Content-Type=video"
* download the original image: http://127.0.0.1:7777/group1/M00/00/00/wKgB8VfiL6KEJ3ZMAAAAAOerjWk419.jpg
* download the resize image: http://127.0.0.1:7777/group1/M00/00/00/wKgB8VfiL6KEJ3ZMAAAAAOerjWk419@200x200.jpg
* download the video: http://127.0.0.1:7777/video1/M00/00/00/wKgB8VfiNpCECq8AAAAAANek-BI696.mp4
* download the videosnapshot: http://127.0.0.1:7777/video1/M00/00/00/wKgB8VfiNpCECq8AAAAAANek-BI696.mp4.jpg
```

## Tips

- Support only HTTP form data submission, not suport http raw submission
- The $cache_path will generate a cache file, you need to clean up by the time stamp
- Upload multiple files at one time
- Comment out "lua_code_cache off;" in nginx.conf
- Upload max file 50M ["client_max_body_size 50m" in nginx.conf, upload:new() in upload_server.lua]
- When uploading files make sure the content-type of form correct
