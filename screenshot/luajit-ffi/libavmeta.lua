

av_meta = {}

local ffi = require 'ffi'
ffi.cdef[[
typedef struct { int duration; int width; int height; int bitrate; } meta_info;
void get_video_meta(uint8_t * file_buff,size_t file_len,meta_info* vm);
void get_audio_meta(uint8_t * file_buff,size_t file_len,meta_info* vm);
]]

local libavmeta = ffi.load('avmeta')

function av_meta.get_video_info(filecontent,filelen)
    local meta = ffi.new("meta_info[1]")
    local buf = ffi.new("char[?]",filelen,filecontent)
    libavmeta.get_video_meta(buf,filelen,meta)
    if meta[0].duration == -1 or meta[0].width == -1 or meta[0].height == -1 then
        return nil
    else
        return meta[0]
    end
end

function av_meta.get_audio_info(filecontent,filelen)
    local meta = ffi.new("meta_info[1]")
    local buf = ffi.new("char[?]",filelen,filecontent)
    libavmeta.get_audio_meta(buf,filelen,meta)
    if meta[0].duration == -1 or meta[0].bitrate == -1 then
        return nil
    else
        return meta[0]
    end
end

return av_meta












