------Import Module--------
local cjson = require "cjson"
local upload = require "resty.upload"
local md5 = require "resty.md5"
local string = require "resty.string"
local tracker = require "resty.fastdfs.tracker"
local storage = require "resty.fastdfs.storage"
local magick = require "magick"
--local videometa = require "libvideometa"
local avmeta = require "libavmeta"

--------------------------Function--------------------------------
function get_filename(res) 
	local filename = ngx.re.match(res,'(.+)filename="(.+)"(.*)') 
	if filename then  
		return filename[2] 
	else
		return nil
	end 
end 

function get_extension(str)
	return str:match(".+%.(%w+)$")
end

function upload_file(fdfs_ip,fdfs_port,buffer,postfix,metainfo)
	local tk = tracker:new()
	tk:set_timeout(3000)
	local ok,err = tk:connect({host=fdfs_ip,port=fdfs_port})
	if not ok then
		ngx.log(ngx.ERR,"connect fastdfs tracker error : ",err)
		return nil
	end
	local stginfo,err = tk:query_storage_store()
	if not stginfo then
		ngx.log(ngx.ERR,"query fastdfs storage error : ",err)
		return nil
	end
        tk:set_keepalive(0,1000)

	local stg = storage:new()
	stg:set_timeout(3000)
	local ok,err = stg:connect(stginfo)		
	if not ok then
		ngx.log(ngx.ERR,"connect fastdfs storage error : ",err)
		return nil
	end

	local rs,err = stg:upload_appender_by_buff(buffer,postfix)
	if not rs then
		ngx.log(ngx.ERR,"upload master file to storage error: ",err)
		return nil
	end
	local groupid = rs.group_name .. "/" .. rs.file_name
	local rs,err = stg:upload_slave_by_buff1(groupid,"-meta",metainfo,"json")
	if not rs then
		ngx.log(ngx.ERR,"upload slave file to storage error : ",err)
		return nil
	end
	stg:set_keepalive(0,1000)

	return groupid 
end

------------------------------------MAIN---------------------------------

local chunk_size = 52428800 --50M
local form,err = upload:new(chunk_size)
if not form then
	ngx.log(ngx.ERR,"fail to new upload: ",err)
	ngx.exit(500)
end
form:set_timeout(3000)

local md5c = md5:new()
local fdfs_ip = nil
local fdfs_port = nil
local result = {}
local filesize = 0
local filename = nil 
local postfix = nil
local filetype = nil
local buffer = ''

while true do
	local stream, res, err = form:read()
	if not stream then
		ngx.log(ngx.ERR,"read socket stream error : ",err)
		ngx.exit(500)
	end
	if stream == "header" then
		if res[1] ~= "Content-Type" then
			filename =  get_filename(res[2])
			postfix = get_extension(filename)
		end
		if res[1] == "Content-Type" then
			filetype = res[2]:sub(1,5)
		end

	elseif stream == "body" then
		md5c:update(res)
                filesize = filesize + #res
		buffer = buffer .. res

	elseif stream == "part_end" then
		local md5_num = md5c:final()
		local md5_hex = string.to_hex(md5_num)
		local filemeta = nil
		--------Meta Info---------
		if     filetype == "image" then
			fdfs_ip = ngx.var.fastdfs_image_tracker_ip
			fdfs_port = ngx.var.fastdfs_image_tracker_port

			local img = magick.load_image_from_blob(buffer)
			if not img then
				ngx.log(ngx.ERR,'load image from buffer error')
				ngx.exit(500)
			end
			filemeta = cjson.encode({size=filesize,ext=postfix,md5=md5_hex,width=img:get_width(),height=img:get_height()})

        elseif filetype == "video" then
			fdfs_ip = ngx.var.fastdfs_video_tracker_ip
			fdfs_port = ngx.var.fastdfs_video_tracker_port

			local vm = avmeta.get_video_info(buffer,filesize)
			if not vm then
				ngx.log(ngx.ERR,'get video info eror')
				ngx.exit(500)
 			end
			filemeta = cjson.encode({size=filesize,ext=postfix,md5=md5_hex,width=vm.width,height=vm.height,duration=vm.duration})

        elseif filetype == "audio" then
			fdfs_ip = ngx.var.fastdfs_video_tracker_ip
			fdfs_port = ngx.var.fastdfs_video_tracker_port

			local am = avmeta.get_audio_info(buffer,filesize)
			if not am then
				ngx.log(ngx.ERR,'get audio info eror')
				ngx.exit(500)
 			end
			filemeta = cjson.encode({size=filesize,ext=postfix,md5=md5_hex,bitrate=am.bitrate,duration=am.duration})

		else
		
		       fdfs_ip = ngx.var.fastdfs_image_tracker_ip
                        fdfs_port = ngx.var.fastdfs_image_tracker_port
                       filemeta = cjson.encode({size=filesize,ext=postfix,md5=md5_hex})
                end
		local groupid = upload_file(fdfs_ip,fdfs_port,buffer,postfix,filemeta)
		if not groupid then
			ngx.log(ngx.ERR,'upload file error')
			ngx.exit(500)
                end
		result[filename] = groupid
		------- Reset Variable ------
		md5c:reset()
		filesize = 0
		filename = ''
		postfix = ''
		filetype = nil
		buffer = ''

	elseif stream == "eof" then
		break		
	else
		ngx.log(ngx.ERR,'stream type error')
		ngx.exit(500)
	end

end
ngx.print(cjson.encode(result))



