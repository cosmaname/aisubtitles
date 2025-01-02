#/usr/bin/env bash
set -e

s=01
seg=300
t=1
pushd ~/Movies/Serial\ S01-S04\ 720p/S${s}
for f in *.mkv ; do
 n=${f%.*}
 echo ${n};
 mkvextract "${n}.mkv" tracks ${t}:"${n}.aac"
 ffmpeg -i "${n}.aac" -f segment -segment_time ${seg} -acodec libmp3lame %d.mp3
 for a in `ls -1 [0-9]*.mp3 | sort -n` ; do
   echo $a
   o=$((${a%.*}*${seg}))
   atranscribe.pl ${a} ${o}.1 > "${a}.en.srt"
   atranslate.pl "${a}.en.srt" >> "${n}.ro.srt"
   sed -i 's/WEBVTT//' "${n}.ro.srt"
 done
done
popd
