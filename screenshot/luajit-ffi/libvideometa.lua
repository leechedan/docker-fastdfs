

videometa = {}

local ffi = require 'ffi'
ffi.cdef[[
typedef struct { int duration; int width; int height; } video_meta;
void get_video_meta(uint8_t * file_buff,size_t file_len,video_meta* vm);
]]

local libvideometa = ffi.load('videometa')

--local content = ffi.new("char[?]",#message)
--ffi.copy(content,message)

function videometa.get_video_info(filecontent,filelen)
    local vm = ffi.new("video_meta[1]")
    local buf = ffi.new("char[?]",filelen,filecontent)
    libvideometa.get_video_meta(buf,filelen,vm)
    if vm[0].duration == -1 or vm[0].width == -1 or vm[0].height == -1 then
        return nil
    else
        return vm[0]
    end
end

return videometa












