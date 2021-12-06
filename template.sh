#!/bin/bash

# 処理1
function job_1() {
  job_reboot
}

# 処理2
function job_2() {
  echo "$1を開始します。よろしいですか？[y/n]"
  read input
  if [ ! "${input,,}" = "y" ] ; then
    echo "処理2 を中断しました"
    return
  fi
  echo "$1が終了しました"
}

# 処理3
function job_3() {
  :
}

# 再起動処理
function job_reboot() {
  echo "再起動しますか？[y/n]"
  read input
  if [ "${input,,}" = "y" ] ; then
#    sudo reboot
     :
  else
    echo "再起動を中断しました"
  fi
}

# 終了処理
function job_exit() {
  echo "終了しますか？[y/n]"
  read input
  if [ "${input,,}" = "y" ] ; then
    exit
  else
    echo "終了を中断しました"
  fi
}

# メイン処理
while :
do
  echo ""
  echo "--------------------------------"
  echo "処理を選択してください"
  echo "1 : 処理1"
  echo "2 : 処理2"
  echo "3 : 処理3"
  echo "q : 終了"
  echo "--------------------------------"

  read input
  echo ""

  case "${input,,}" in
    "1") job_1 "処理1" ;;
    "2") job_2 "処理2" ;;
    "3") job_3 "処理3" ;;
    "q") job_exit ;;
    *)  echo "1～3、q を入力してください" ;;
  esac
done
