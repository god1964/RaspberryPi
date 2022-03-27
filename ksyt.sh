#/bin/bash
function menu {
  # メニューカーソルの位置
  choice=0
  # メニュー配列
  menu=(
    "ydYDqZQpim8 Namibia: Live stream in the Namib Desert"
    "DAJYk1jOhzk Let It Go - Frozen - Alex Boyé (Africanized Tribal Cover) Ft. One Voice Children's Choir"
    "StLHSkvz3Rk 【鬼滅の刃 Demon Slayer: Kimetsu no Yaiba】和楽 紅蓮華【LiSA/紅蓮華 Gurenge】"
    "UvouZBYuijM JOKER | Don't Stop Me Now"
    "elJc256ekw4 【BGMギターカバー】沙羅曼蛇(1986KONAMI/AC))全曲メドレー"
    "PL6PHQCxAqpJTA3R5hgkqVJChfIuecx2gh Cho Ren Sha 68K Original Soundtracks Complete"
  )
  tail=$((${#menu[@]} - 1)) # メニューの末尾番号
  printf "\e[32mq:メニュー終了, Q:kodi終了, c:ダイアログ閉じる, e:選択, b:戻る, u:カーソル上移動, d:カーソル下移動, l:カーソル左移動, r:カーソル右移動, p:一時停止／再開, s:停止, n:次の動画, f:前の動画, o:お気に入りを開く, -:音量下げる, +:音量挙げる, t:スクショ, m:ミュート／解除, k:kodi起動\e[m\n"  >&2
  for _ in $(seq 0 $tail);do echo "";done

  # 無限ループ
  while true
  do
    printf "\e[${#menu[@]}A\e[m" >&2

    for i in $(seq 0 $tail);do
      if [ $choice = $i ]; then
        printf "\e[1;31m>\e[m \e[1;4m" >&2
      else # メニューが選択中でなければ
        printf "  " >&2
      fi
      title=`echo ${menu[$i]} | sed -e "s/^[^ ]*[ ]//"`
      printf "$title\e[m\n" >&2
    done

    read -sn1 input

    # ショートカット処理
    case $input in
      "q") return ;;
      "Q") kodi-send -a Quit > /dev/null ;;
      "c") kodi-send -a "Action(Close)" > /dev/null ;;
      "e") kodi-send -a "Action(Select)" > /dev/null ;;
      "b") kodi-send -a "Action(Back)" > /dev/null ;;
      "u") kodi-send -a "Action(Up)" > /dev/null ;;
      "d") kodi-send -a "Action(Down)" > /dev/null ;; 
      "l") kodi-send -a "Action(Left)" > /dev/null ;;
      "r") kodi-send -a "Action(Right)" > /dev/null ;;
      "p") kodi-send -a "Action(PlayPause)" > /dev/null ;; 
      "s") kodi-send -a "Action(Stop)" > /dev/null ;;
      "n") kodi-send -a "Action(SkipNext)" > /dev/null ;;
      "f") kodi-send -a "Action(SkipPrevious)" > /dev/null ;;
      "o") kodi-send -a "ActivateWindow(favourites)" > /dev/null ;;
      "-") kodi-send -a "Action(VolumeDown)" > /dev/null ;;
      "+") kodi-send -a "Action(VolumeUp)" > /dev/null ;;
      "t") kodi-send -a "TakeScreenshot" > /dev/null ;;
      "m") kodi-send -a "Mute" > /dev/null ;;
      "k")
        ps=`ps aux | grep "/bin/sh /usr/bin/kodi" | grep -v grep | wc -l`
        if [ $ps -eq 0 ]; then
          /bin/sh /usr/bin/kodi & > /dev/null
        fi
        ;;
    esac

    # メニュー制御
    if [ "$input" = "" ]; then # (^[はctrl+V ctrl+[とかで入力してね)
      read -sn2 input
    fi
    case $input in
      "j"|"[B") choice=$((choice + 1)); if [ $choice -gt $tail ]; then choice=0; fi ;;
      "k"|"[A") choice=$((choice - 1)); if [ $choice -lt 0 ]; then choice=$tail; fi ;;
      "")
        # 改行で決定
        ./ksid.sh `echo ${menu[$choice]} | awk '{print $1}'`
        ;;
    esac
  done
}

menu

