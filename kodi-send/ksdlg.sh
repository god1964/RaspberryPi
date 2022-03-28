#!/bin/bash

menu_file=./ksdlg_menu.txt
DATA=`cat $menu_file`

while true; do
  str="dialog --menu \"一覧:\" 0 0 0 "
  i=1
  while read line
  do
    str+="$i "
    title=`echo $line | sed -e "s/^[^ ]*[ ]//"`
    str+="\"${title}\" "
    i=$((i + 1))
  done << FILE
$DATA
FILE

  str+="2>temp"
  eval $str

  # OK が押されたら
  if [ "$?" = "0" ]; then
    _return=$(cat temp)
    i=1
    while read line
    do
      if [ $_return -eq $i ]; then
        break
      fi
      i=$((i + 1))
    done << FILE
$DATA
FILE

    ./ksid.sh `echo $line | awk '{print $1}'`
  else
    break
  fi

  rm -f temp
done
