#!/bin/bash

PS3="请输入项目编号: "

node_project=(
  network3 
  waku
)

network3(){
  wget -O ~/0g.sh https://raw.githubusercontent.com/lmooop/lm/main/network3.sh && chmod +x ~/network3.sh && ~/network3.sh
}

waku(){
   wget -O ~/waku.sh https://raw.githubusercontent.com/lmooop/lm/main/waku.sh && chmod +x ~/waku.sh && ~/waku.sh
}

function main_menu() {
  logo
  select p in ${node_project[@]}
  do
    $p
    break;
  done
}

logo()
{
echo -e '\033[33m      _  __        __    __  ___         __          \033[0m'
echo -e '\033[33m     / |/ /__  ___/ /__ /  |/  /__ ____ / /____ ____ \033[0m'    
echo -e '\033[33m    /    / _ \/ _  / -_) /|_/ / _ `(_-</ __/ -_) __/ \033[0m'    
echo -e '\033[33m   /_/|_/\___/\_,_/\__/_/  /_/\_,_/___/\__/\__/_/    \033[0m'
echo -e '\033[33m                                                     \033[0m'
}

main_menu
