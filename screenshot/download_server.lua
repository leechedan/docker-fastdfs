
local tracker = require "resty.fastdfs.tracker"
local storage = require "resty.fastdfs.storage"

function download_file(ip,port,groupid)

	local tk = tracker:new()
	tk:set_timeout(3000)
	local ok,err = tk:connect({host=ip,port=port})
	if not ok then
		ngx.log(ngx.ERR,"connect fastdfs tracker error: ", err, " groupid:", groupid)
		return
	end
	local stginfo,err = tk:query_storage_fetch1(groupid)
	if not stginfo then
		ngx.log(ngx.ERR,"query fastdfs storage error: ", err, " groupid:", groupid)
		return
	end
        tk:set_keepalive(0,1000)	

	local st = storage:new()
	st:set_timeout(3000)
	local ok, err = st:connect(stginfo)
	if not ok then
	    ngx.log(ngx.ERR,"connect storage error: ", err, " groupid:", groupid)
	    return
	end

	local buffer,err = st:download_file_to_buff1(groupid)
	if not buffer then
	    ngx.log(ngx.ERR,"download from fastdfs storage error: ", err, " groupid:", groupid)
	    return
	end
        st:set_keepalive(0,1000) 

        return buffer
end

function is_file_exists(filepath)
	local fd = io.open(filepath,"r")
	if fd then
		fd:close()
		return true
	else
		return false
	end
end

----------------------MAIN------------------------------

local fdfs_ip   = ngx.var.fastdfs_tracker_ip
local fdfs_port = ngx.var.fastdfs_tracker_port
local cache_path = ngx.var.cache_path
local filename = ngx.var.filename
local orgfilename = ngx.var.original_file
local filepath = cache_path .. filename
local orgfilepath = cache_path .. orgfilename
local groupid = ngx.var.group_id:sub(2,-1)
local media = ngx.var.media;
local image_size = ngx.var.image_size
local postfix = ngx.var.postfix

#ngx.log(ngx.ERR,"uri:",ngx.var.uri)
#ngx.log(ngx.ERR,"postfix:",postfix)
#ngx.log(ngx.ERR,"filename:",filename)
#ngx.log(ngx.ERR,"filepath:",filepath)
#ngx.log(ngx.ERR,"imagesize:",image_size)
#ngx.log(ngx.ERR,"groupid:",groupid)
#ngx.log(ngx.ERR,"originalfile:",orgfilename)
#ngx.log(ngx.ERR,"originalfilepath:",orgfilepath)


local buffer = nil
if not is_file_exists(orgfilepath) then
	buffer = download_file(fdfs_ip,fdfs_port,groupid)
	if not buffer then
	    ngx.log(ngx.ERR,"download from fastdfs storage error:", err)
	    ngx.exit(500)
	end
	local wfd = io.open(orgfilepath,"w")
	if not wfd then
	    ngx.log(ngx.ERR,"write file error:", orgfilepath)
	    ngx.exit(500)
	end
	wfd:write(buffer)
	wfd:close()
	ngx.log(ngx.ERR,"write ok")
end

if media == '1' then
	if image_size ~= '' then
		local cmd = "gm convert " .. orgfilepath .. " -thumbnail " .. image_size .. " " .. filepath
		local ret = os.execute(cmd)
		local rfd = io.open(filepath,"r")
		if not rfd then
		    ngx.log(ngx.ERR,"read file error:", filepath)
		    ngx.exit(500)
		end
		buffer = rfd:read("*a")
		rfd:close()
	end
elseif media == '2' then 
	local cmd = "ffmpeg -v 0 -ss 1 -i " .. orgfilepath .. " -vframes 1 -f image2 -y " .. filepath
	local ret = os.execute(cmd)
        local cmd1 = "ffprobe -i " .. orgfilepath .. " -v quiet -print_format json  -show_streams -select_streams 1 >" .. cache_path .. ngx.var.prefix .. "-me.json"	
	os.execute(cmd1)
	local rfd = io.open(filepath,"r")
	if not rfd then
	    ngx.log(ngx.ERR,"read file error:", filepath)
	    ngx.exit(500)
	end
	buffer = rfd:read("*a")
	rfd:close()

elseif media == '3' then
	--download audio amr file	
else
	ngx.log(ngx.ERR,'media type error : ', media)
	ngx.exit(500)
end

ngx.print(buffer)
buffer = nil
