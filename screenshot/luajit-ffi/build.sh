#!/bin/bash


#uncomment main function
#gcc libvideometa.c -o videometa -I/usr/local/include -lavformat -lavdevice -lavcodec -lavutil -lavfilter -lswresample -lswscale -lm -llzma -lbz2 -lz -pthread
#valgrind --tool=memcheck ./videometa  xxxx.mp4

#uncomment main function
#gcc libavmeta.c -o avmeta -I/usr/local/include  -lavformat -lavdevice -lavcodec -lavutil -lavfilter -lswresample -lswscale -lm -llzma -lbz2 -lz -pthread
#valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all ./avmeta xxxxxx

gcc  libvideometa.c -shared -O2 -fPIC -o libvideometa.so -I/usr/local/include -L/usr/local/include -lavformat -lavdevice  -lavcodec -lavutil  -lavfilter  -lswresample -lswscale -lm -llzma -lbz2 -lz -pthread
gcc  libavmeta.c -shared -O2 -fPIC -o libavmeta.so -I/usr/local/include -L/usr/local/include -lavformat -lavdevice  -lavcodec -lavutil  -lavfilter  -lswresample -lswscale -lm -llzma -lbz2 -lz -pthread

