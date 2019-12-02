//#include <stdio.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavformat/avio.h>
#include <libavutil/file.h>

struct buffer_data {
    uint8_t *ptr;
    size_t size; // size left in the buffer
};

typedef struct {
      int duration; 
      int width;
      int height;
} video_meta;

static int read_packet(void *opaque, uint8_t *buf, int buf_size)
{
    struct buffer_data *bd = (struct buffer_data *)opaque;
    buf_size = FFMIN(buf_size, bd->size);
    //printf("ptr:%p size:%zu\n", bd->ptr, bd->size);
    memcpy(buf, bd->ptr, buf_size);
    bd->ptr  += buf_size;
    bd->size -= buf_size;
    return buf_size;
}

void get_video_meta(uint8_t * file_buff,size_t file_len, video_meta* vm)
{
    //指针为空在外部判断
    vm->duration = -1;
    vm->width = -1;
    vm->height = -1;

    int ret;
    AVFormatContext *fmt_ctx = NULL;
    AVIOContext *avio_ctx = NULL;
    uint8_t *avio_ctx_buffer = NULL;
    size_t avio_ctx_buffer_size = 524288;

    struct buffer_data bd = {0};
    bd.ptr = file_buff;
    bd.size = file_len;

    av_register_all();

    fmt_ctx = avformat_alloc_context();
    if(!fmt_ctx){    
        return;
    }
  
    avio_ctx_buffer = av_malloc(avio_ctx_buffer_size);
    if (!avio_ctx_buffer) {
        avformat_free_context(fmt_ctx);
        return;
    }

    avio_ctx = avio_alloc_context(avio_ctx_buffer, avio_ctx_buffer_size, 0, &bd, &read_packet, NULL, NULL);
    if (!avio_ctx) {
        av_freep(&avio_ctx_buffer);
        avformat_free_context(fmt_ctx);
        return;
    }

    fmt_ctx->pb = avio_ctx;   

    ret = avformat_open_input(&fmt_ctx, NULL, NULL, NULL);
    if (ret < 0) {
        av_freep(&avio_ctx->buffer); 
        av_freep(&avio_ctx);
        avformat_free_context(fmt_ctx);
        return;
    }

    int stream_index = av_find_best_stream(fmt_ctx,AVMEDIA_TYPE_VIDEO,-1,-1,NULL,0);
    if(stream_index < 0){
        avformat_close_input(&fmt_ctx);
        av_freep(&avio_ctx->buffer); 
        av_freep(&avio_ctx);
        avformat_free_context(fmt_ctx);
        return;
    }

    if (fmt_ctx->duration != AV_NOPTS_VALUE){
         int nsec = fmt_ctx->duration + (fmt_ctx->duration <= INT64_MAX - 5000 ? 5000 : 0);
         vm->duration = nsec / 1000000;
    }

    AVStream *st = fmt_ctx->streams[stream_index];
    vm->width = st->codecpar->width;
    vm->height = st->codecpar->height;

    avformat_close_input(&fmt_ctx);
    av_freep(&avio_ctx->buffer); 
    av_freep(&avio_ctx);
    avformat_free_context(fmt_ctx);
    return;
}
/*
int main(int argc,char * argv[])
{
    char *input_filename = argv[1];
    FILE *fp = fopen(input_filename,"r");
    fseek(fp,0,SEEK_END);
    size_t filelen = ftell(fp);
    uint8_t * read_buff = malloc(filelen);
    fseek(fp,0,SEEK_SET);
    fread(read_buff,filelen,1,fp);    
    fclose(fp);

    video_meta vm;
    get_video_meta(read_buff,filelen,&vm);
    printf("Width:%d,Height:%d,Duration:%d\n",vm.width,vm.height,vm.duration);
    free(read_buff);
}
*/






