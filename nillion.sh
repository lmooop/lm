安装nillion验证者(){
  apt install jq -y
  curl -fssl https://get.docker.com | bash -s docker
  docker pull nillion/retailtoken-accuser:v1.0.0
  cd
  mkdir -p nillion/accuser
  docker run --rm -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 initialise
  echo "你的AccountID:"
  cat ~/nillion/accuser/credentials.json|jq -r .address
  echo "你的PublicKey:"
  cat ~/nillion/accuser/credentials.json|jq -r .pub_key
  read -p $'请按教程在网页认证后，输入你的block-start:\n' h

  echo $h > ~/nillion/accuser/block-start
  docker run --restart=always -d --name nillion_verifier -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com" --block-start
  echo "请等待 30-60 分钟后检查节点日志"
}

更新rpc(){
  cd
  docker rm -f nillion_verifier
  read -p $'请输入 rpc 地址: \n' rpc
  h=`cat ~/nillion/accuser/block-start`
  docker run --restart=always -d --name nillion_verifier -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint "$rpc" --block-start ${h}
}

查看日志(){
  docker logs nillion_verifier --tail 100
}
重启nillion验证者(){
  block_start=`cat ~/nillion/accuser/block-start`
  docker run --restart=always -d --name nillion_verifier -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com" --block-start ${block_start}
  docker logs nillion_verifier --tail 100
}
options=(
安装nillion验证者
重启nillion验证者
更新rpc
查看日志
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
  logo
  select p in ${options[@]}
    do
      $p
      echo "-===================NodeMaster============================-"
      break;
    done
}
menu
