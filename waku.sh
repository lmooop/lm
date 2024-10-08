#!/bin/bash

# 安装节点函数
安装() {
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

    # 检测Docker安装是否成功
    if ! command -v docker &> /dev/null; then
        echo "安装 Docker ..."
        sudo apt install -y docker.io 
        if ! command -v docker &> /dev/null; then
            echo "安装 Docker 失败，请检查错误信息。"
            exit 1
        fi
    fi

    # 检查是否需要安装Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "安装 Docker Compose ..."
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        if ! command -v docker-compose &> /dev/null; then
            echo "安装 Docker Compose 失败，请检查错误信息。"
            exit 1
        fi
    fi

    #rm -rf ./nwaku-compose
    if [ -d "nwaku-compose" ]; then
        read -r -p "是否卸载重装，Y 卸载重装(重装前请手动备份)[Y/n] " input
        case $input in
            [yY][eE][sS]|[yY])
        		echo "Yes"
            rm -rf ./nwaku-compose
        		;;
        
            [nN][oO]|[nN])
        		echo "No"
        		  exit 1
               	;;
        
            *)
        		echo "Invalid input..."
        		exit 1
        		;;
        esac
    fi
    git clone https://github.com/waku-org/nwaku-compose && cd ./nwaku-compose
    cp .env.example .env
    read -p $'输入RPC地址,e.g. https://sepolia.infura.io/v3/123aa110320f4aec179150fba1e1b1b1:\n' RLN_RELAY_ETH_CLIENT_ADDRESS
    read -p $'输入钱包私钥,不带0x,e.g. 0116196e9a8abed42dd1a22eb63fa2a5a17b0c27d716b87ded2c54f1bf192a0b:\n' ETH_TESTNET_KEY
    read -p $'自定义密码,e.g. 123400800Ib:\n' RLN_RELAY_CRED_PASSWORD

    sed -i "s#RLN_RELAY_ETH_CLIENT_ADDRESS=.*#RLN_RELAY_ETH_CLIENT_ADDRESS=${RLN_RELAY_ETH_CLIENT_ADDRESS}#g" ~/nwaku-compose/.env
    sed -i "s#ETH_TESTNET_KEY=.*#ETH_TESTNET_KEY=${ETH_TESTNET_KEY}#g" ~/nwaku-compose/.env
    sed -i "s#RLN_RELAY_CRED_PASSWORD=.*#RLN_RELAY_CRED_PASSWORD=\"${RLN_RELAY_CRED_PASSWORD}\"#g" ~/nwaku-compose/.env
    ./register_rln.sh
    docker-compose up -d
    ip=$(curl ipinfo.io/ip)
    echo -e "\033[31m http://$ip:3000/d/yns_4vFVk/nwaku-monitoring \033[0m"
}

添加发送消息脚本(){
cat > ~/waku_messages.sh << EOF
#!/bin/bash
time=\$(date "+%Y-%m-%d %H:%M:%S")

curl -X POST "http://127.0.0.1:8645/relay/v1/auto/messages" \
 -H "content-type: application/json" \
 -d '{"payload":"'\$(echo -n "hello world UTC:\$time" | base64)'","contentTopic":"/my-app/2/chatroom-1/proto"}'

curl -X GET "http://127.0.0.1:8645/store/v1/messages?contentTopics=%2Fmy-app%2F2%2Fchatroom-1%2Fproto&pageSize=50&ascending=true" \
 -H "accept: application/json"|jq .
EOF
  exist=$(crontab -l|grep -E "waku_messages")        
  if [ ! "$exist" ] ; then 
    chmod +x ~/waku_messages.sh
    (crontab -l;echo "*/20 * * * * bash ~/waku_messages.sh") | crontab
  fi
  crontab -l
}
options=(
安装
添加发送消息脚本
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
