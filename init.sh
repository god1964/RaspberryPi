#!/bin/bash
############################################################
# Script name: init.sh
# Modify     : 2021.12.01 GOD 初版作成
# Usage      : bash ./init.sh
############################################################

############################################################
# パラメータ定義
#
# interface          : 無線LAN="interface wlan0"、有線LAN="interface eth0"
# ip_address         : 固定IPアドレス
# routers            : ルーターアドレス。通例 192.168.*.1 か 192.168.*.254
# domain_name_servers: DNSサーバーの IPアドレス
# 
# ssid_buff          : SSID
# psk_buff           : パスワード
# 
# confirm            : 確認メッセージ表示=true、確認メッセージ非表示=false
# diff_switch        : diffコマンド引数。未指定、-c、-u 等々
############################################################
# メニュー「2  : IPアドレス固定」が使用するパラメータ
interface="interface wlan0"
ip_address="192.168.11.***/24"
routers="192.168.11.1"
domain_name_servers="192.168.11.1"

# メニュー「8  : 複数AP対応 WiFi設定」が使用するパラメータ
ssid_buff[0]="***"
ssid_buff[1]="***"
ssid_buff[2]="***"

psk_buff[0]="***"
psk_buff[1]="***"
psk_buff[2]="***"

# メニュー「9  : 各種インストール」が使用するパラメータ
install_buff[0]="screen"
install_buff[1]="kodi"
install_buff[2]="wavemon"
install_buff[3]="iperf3"
install_buff[4]="gparted"

confirm=false
diff_switch=""

cancel=false

############################################################
# 関数定義
############################################################
#
# パッケージ更新
#
function job_1() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  sudo apt update -y && sudo apt full-upgrade -y && \
  sudo apt autoremove -y && sudo apt-get clean -y && sudo apt autoclean -y

  echo "$1が終了しました"
}

#
# IPアドレス固定
#
function job_2() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  dest_file=/etc/dhcpcd.conf
  add_str="static ip_address=$ip_address"
  ret=true
  if ! grep -q "$add_str" $dest_file ; then
    sudo cat <<EOL >> $dest_file
$interface
$add_str
static routers=$routers
static domain_name_servers=$domain_name_servers
EOL

    # 追記内容確認
    tail $dest_file
    ret=false
  else
    echo "設定済みです"
  fi

  echo "$1が終了しました"

  if ! "${ret}" ; then
    # 再起動処理
    job_reboot
  fi
}

#
# Swap領域無効化
#
function job_3() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  sudo swapoff --all && sudo apt purge -y --auto-remove dphys-swapfile && sudo rm -fr /var/swap

  dest_file=/etc/fstab
  add_str1="tmpfs           /tmp            tmpfs   defaults,size=32m,noatime,mode=1777  0       0"
  add_str2="tmpfs           /var/tmp        tmpfs   defaults,size=16m,noatime,mode=1777  0       0"
  ret=true
  if ! grep -q "$add_str1" $dest_file ; then
  cat <<EOL | sudo tee -a $dest_file
$add_str1
$add_str2
192.168.11.101:/media/pi/WD8T01  /mnt/nfs/WD8T01  nfs  _netdev,nofail,rw,defaults,nfsvers=3  0   0
192.168.11.101:/media/pi/SG8T03  /mnt/nfs/SG8T03  nfs  _netdev,nofail,rw,defaults,nfsvers=3  0   0
192.168.11.101:/media/pi/SG8T05  /mnt/nfs/SG8T05  nfs  _netdev,nofail,rw,defaults,nfsvers=3  0   0
EOL

    # 追記内容確認
    cat $dest_file
    ret=false
  else
    echo "設定済みです"
  fi

  echo "$1が終了しました"

  if ! "${ret}" ; then
    # 再起動処理
    job_reboot
  fi
}

#
# rsyslogログ出力抑制
#
function job_4() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  dest_file=/etc/rsyslog.conf
  bak_file=`job_bak_file $dest_file`
  if ! grep -q "^#daemon\.\*"$'\t'".*$" $dest_file ; then
    sudo cp $dest_file $bak_file

    sudo sed -i \
      -e "s/^\(daemon\.\*"$'\t'".*$\)/#\1/" \
      -e "s/^\(kern\.\*"$'\t'".*$\)/#\1/" \
      -e "s/^\(lpr\.\*"$'\t'".*$\)/#\1/" \
      -e "s/^\(mail\.\*"$'\t'".*$\)/#\1/" \
      -e "s/^\(user\.\*"$'\t'".*$\)/#\1/" \
      -e "s/^\(mail\.info"$'\t'".*$\)/#\1/" \
      -e "s/^\(mail\.warn"$'\t'".*$\)/#\1/" \
      -e "s/^\(mail\.err"$'\t'".*$\)/#\1/" \
    $dest_file && \
    sudo sed -i -z -e \
      "s/\(\*\.=debug;\\\\\).*\("$'\t'"auth,authpriv.none;\\\\\).*\("$'\t'"mail\.none.*-\/var\/log\/debug\)/#\1\n#\2\n#\3/" \
    $dest_file

    job_diff $bak_file $dest_file

    sudo systemctl restart rsyslog
  else
    echo "設定済みです"
  fi

  echo "$1が終了しました"
}

#
# heartbeat設定
#
function job_5() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  dest_file=/boot/config.txt
  bak_file=`job_bak_file $dest_file`
  ret=true
  if ! grep -q "dtparam=pwr_led_trigger=heartbeat" $dest_file ; then
    sudo cp $dest_file $bak_file
    cat <<EOL | sudo tee -a $dest_file
# turn power LED into heartbeat
dtparam=pwr_led_trigger=heartbeat
#
EOL

    # 追記内容確認
    tail $dest_file
    ret=false
  else
    echo "設定済みです"
  fi

  echo "$1が終了しました"

  if ! "${ret}" ; then
    # 再起動処理
    job_reboot
  fi
}

#
# Watchdog Timer設定
#
function job_6() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  sudo apt install watchdog -y

  dest_file=/lib/systemd/system/watchdog.service
  bak_file=`job_bak_file $dest_file`
  ret=true
  if ! grep -q "WantedBy=Multi-user.target" $dest_file ; then
    sudo cp $dest_file $bak_file

    sudo sed -i -e "s/^\(WantedBy=default.target$\)/#\1/" $dest_file
    cat <<EOL | sudo tee -a $dest_file
WantedBy=Multi-user.target
EOL

    job_diff $bak_file $dest_file

    sudo update-rc.d watchdog enable && sudo modprobe bcm2835_wdt
    ret=false
  else
    echo "設定済みです"
  fi

  dest_file=/etc/watchdog.conf
  bak_file=`job_bak_file $dest_file`
  ret=true
  if ! grep -q "watchdog-timeout = 10" $dest_file ; then
    sudo cp $dest_file $bak_file

    sudo sed -i -e "s/^#\(max-load-1.*= 24$\)/\1/" $dest_file
    sudo sed -i -e "s/^#\(watchdog-device.*= \/dev\/watchdog$\)/\1/" $dest_file
    cat <<EOL | sudo tee -a $dest_file
watchdog-timeout = 10
EOL

    job_diff $bak_file $dest_file
    ret=false
  else
    echo "設定済みです"
  fi

  echo "$1が終了しました"

  if ! "${ret}" ; then
    # 再起動処理
    job_reboot
  fi
}

#
# Watchdog Timer設定後のハングアップテスト
#
function job_7() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  # 再起動後ハングアップテスト
  :(){ :|:& };:

  echo "$1を開始しました"
}

#
# 複数AP対応 WiFi設定
#
function job_8() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  if [ ! ${!ssid_buff[@]} -eq ${!psk_buff[@]} ]; then
    echo "ssid_buff と psk_buff の定義数が異なります。$1を中断しました"
    return
  fi

  dest_file=/etc/wpa_supplicant/wpa_supplicant.conf
  bak_file=`job_bak_file $dest_file`
  if ! grep -q "Extender-A-6380" $dest_file ; then
    sudo cp $dest_file $bak_file

    cat <<EOL | sudo tee $dest_file
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=JP
EOL

    for i in ${!ssid_buff[@]}
    do
      cat <<EOL | sudo tee -a $dest_file

network={
        ssid="${ssid_buff[$i]}"
        psk="${psk_buff[$i]}"
        priority=$(($i+1))
}
EOL
    done

    job_diff $bak_file $dest_file
  else
    echo "設定済みです"
  fi

  echo "$1が終了しました"
}

#
# 各種インストール
#
function job_9() {
  job_confirm $1
  if "${cancel}" ; then
    return
  fi

  for i in ${!install_buff[@]}
  do
    set -x
    sudo apt install "${install_buff[$i]}" -y
    set +x
  done

  echo "$1が終了しました"
}

#
# バックアップファイル名作成
#
function job_bak_file() {
  echo $1"_bak_"`date "+%Y%m%d_%H%M%S"`
}

#
# ファイル比較
#
function job_diff() {
  echo ""
  diff $diff_switch $1 $2
  echo ""
}

#
# 確認
#
function job_confirm() {
  cancel=false
  if "${confirm}" ; then
    echo "$1を開始します。よろしいですか？[y/n]"
    read input
    if [ "${input,,}" != "y" ] ; then
      echo "$1を中断しました"
      cancel=true
      return
    fi
  else
    echo "$1を開始します。"
  fi
}

#
# 再起動処理
#
function job_reboot() {
  echo "再起動しますか？[y/n]"
  read input
  if [ "${input,,}" = "y" ] ; then
    sudo reboot
  else
    echo "再起動を中断しました"
  fi
}

#
# 終了処理
#
function job_exit() {
  if "${confirm}" ; then
    echo "終了しますか？[y/n]"
    read input
    if [ "${input,,}" != "y" ] ; then
      echo "終了を中断しました"
      return
    fi
  fi

  exit
}

#
# シャットダウン
#
function job_poweroff() {
  echo "シャットダウンしますか？[y/n]"
  read input
  if [ "${input,,}" = "y" ] ; then
    sudo poweroff
  else
    echo "シャットダウンを中断しました"
  fi
}

############################################################
# メイン処理
############################################################
while :
do
  echo ""
  echo "--------------------------------"
  echo "処理を選択してください"
  echo "1  : パッケージ更新"
  echo "2  : IPアドレス固定"
  echo "3  : Swap領域無効化"
  echo "4  : rsyslogログ出力抑制"
  echo "5  : heartbeat設定"
  echo "6  : Watchdog Timer設定"
  echo "7  : Watchdog Timer設定後のハングアップテスト"
  echo "8  : 複数AP対応 WiFi設定"
  echo "9  : 各種インストール"
  echo "q  : 終了"
  echo "r  : 再起動"
  echo "p  : シャットダウン"
  echo "--------------------------------"

  read input
  echo ""

  case "${input,,}" in
    "1")  job_1  "パッケージ更新" ;;
    "2")  job_2  "IPアドレス固定" ;;
    "3")  job_3  "Swap領域無効化" ;;
    "4")  job_4  "rsyslogログ出力抑制" ;;
    "5")  job_5  "heartbeat設定" ;;
    "6")  job_6  "Watchdog Timer設定" ;;
    "7")  job_7  "Watchdog Timer設定後のハングアップテスト" ;;
    "8")  job_8  "複数AP対応 WiFi設定" ;;
    "9")  job_9  "各種インストール" ;;
    "q")  job_exit ;;
    "r")  job_reboot ;;
    "p")  job_poweroff ;;
    *)  echo "1～9、q、r、p を入力してください" ;;
  esac
done
