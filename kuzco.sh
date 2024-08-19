#!/bin/bash
安装节点(){
  curl -fsSL https://kuzco.xyz/install.sh | sh 
  read -p $'输入节点--code: \n' code
  wget -O ~/kuzco.py https://raw.githubusercontent.com/lmooop/lm/main/kuzco.py
	sed -i 's#code=""#code="'$code'"#' ~/kuzco.py
	screen -dmS kuzco bash -c 'python3 ~/kuzco.py'
}

options=(
安装节点
卸载节点
)

logo()
{
echo -e '\033[33m      _  __        __    __  ___         __          \033[0m'
echo -e '\033[33m     / |/ /__  ___/ /__ /  |/  /__ ____ / /____ ____ \033[0m'    
echo -e '\033[33m    /    / _ \/ _  / -_) /|_/ / _ `(_-</ __/ -_) __/ \033[0m'    
echo -e '\033[33m   /_/|_/\___/\_,_/\__/_/  /_/\_,_/___/\__/\__/_/    \033[0m'
echo -e '\033[33m                                                     \033[0m'
}

menu() {
  clear
  PS3="请输入编号: "
  # logo
  while true
    do
      logo
      select p in ${options[@]}
        do
          $p
          echo "-===================NodeMaster============================-"
          break;
        done
    done
}
menu
