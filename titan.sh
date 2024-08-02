#!/bin/bash

安装() {
    if ! command -v docker &> /dev/null; then
        echo "安装 Docker ..."
        sudo apt install -y docker.io 
        if ! command -v docker &> /dev/null; then
            echo "安装 Docker 失败，请检查错误信息。"
            exit 1
        fi
        systemctl enable docker
    fi
    docker pull nezha123/titan-edge:1.6_amd64
    mkdir -pv ~/.titanedge
    read -p $'输入节点 id: \n' id
    read -p $'分配存储大小,单位G: \n' storage


    docker run -d --restart always -v "/root/.titanedge:/root/.titanedge" \
      --net=host \
      --name "titan" \
      nezha123/titan-edge:1.6_amd64
    sleep_time
    # docker exec $container_id bash -c "\
    sed -i 's#\#StorageGB = .*#StorageGB = '$storage'#' ~/.titanedge/config.toml
    sed -i 's#\#ListenAddress = .*#ListenAddress = \"0.0.0.0:10086\"#' ~/.titanedge/config.toml
    docker restart titan && \
      docker ps -a |grep "titan"
    docker exec titan bash -c "\
        titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
    echo "titan 安装成功...."
}

options=(
安装
)

sleep_time() {
    sleep=30
    while [ $sleep -gt 0 ];do
      echo -n 等待${sleep}s......
      sleep 1
      sleep=$(($sleep - 1))
      echo -ne "\r     \r"
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
