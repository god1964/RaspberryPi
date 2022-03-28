#!/bin/bash

# 引数未指定の場合
if [ $# -ne 1 ]; then
  echo "使用法: $0 [動画ID | プレイリストID]" 1>&2
  echo "        YouTube 動画ID、またはプレイリストID を指定してください。" 1>&2
  exit 1
fi

if [ ${#1} = 11 ]; then
  kodi-send -a "PlayMedia(plugin://plugin.video.youtube/play/?video_id=$1,resume)" > /dev/null
else
  kodi-send -a "PlayMedia(plugin://plugin.video.youtube/play/?playlist_id=$1&play=1&order=default)" > /dev/null
fi

