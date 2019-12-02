

local avmeta = require "libavmeta"

if not arg[1] then
	print('useage: luajit test.lua xxxxxxxx.mp4' )
	return
end

local fp = io.open(arg[1])
local data = fp:read("*a")

local vm = avmeta.get_video_info(data,#data)
if vm then
	print(vm.duration,vm.height,vm.width)
end

local vm = avmeta.get_audio_info(data,#data)
if vm then
	print(vm.duration,vm.bitrate)
end 





