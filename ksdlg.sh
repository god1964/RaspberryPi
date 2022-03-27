#!/bin/bash

menu=(
    "ydYDqZQpim8 Namibia: Live stream in the Namib Desert"
    "DAJYk1jOhzk Let It Go - Frozen - Alex Boyé (Africanized Tribal Cover) Ft. One Voice Children's Choir"
    "StLHSkvz3Rk 【鬼滅の刃 Demon Slayer: Kimetsu no Yaiba】和楽 紅蓮華【LiSA/紅蓮華 Gurenge】"
    "UvouZBYuijM JOKER | Don't Stop Me Now"
    "elJc256ekw4 【BGMギターカバー】沙羅曼蛇(1986KONAMI/AC))全曲メドレー"
    "PL6PHQCxAqpJTA3R5hgkqVJChfIuecx2gh Cho Ren Sha 68K Original Soundtracks Complete"
)

while true; do
  str="dialog --menu \"一覧:\" 0 0 0 "
  for i in $(seq 0 $((${#menu[@]} - 1)));do
    str+="$((i + 1)) "
    title=`echo ${menu[$i]} | sed -e "s/^[^ ]*[ ]//"`
    str+="\"${title}\" "
  done
  str+="2>temp"
  eval $str

  # OK が押されたら
  if [ "$?" = "0" ]; then
    _return=$(cat temp)
    ./ksid.sh `echo ${menu[$(($_return - 1))]} | awk '{print $1}'`

#      id=`echo ${menu[$(($_return - 1))]} | awk '{print $1}'`

#      if [ ${#id} = 11 ]; then
#        kodi-send -a "PlayMedia(plugin://plugin.video.youtube/play/?video_id=$id)" > /dev/null
#      else
#        kodi-send -a "PlayMedia(plugin://plugin.video.youtube/play/?playlist_id=$id&play=1&order=default)" > /dev/null
#      fi
#      sleep 1
#      kodi-send -a "Action(Select)" > /dev/null
  else
    break
  fi

  rm -f temp
done

