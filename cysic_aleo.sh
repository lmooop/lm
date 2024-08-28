#!/bin/bash
CYSIC_AGENT_PATH="$HOME/cysic-prover-agent"
CYSIC_PROVER_PATH="$HOME/cysic-aleo-prover"

install_dependencies() {
    apt update && apt upgrade -yq
    apt install curl wget -yq
    if command -v node > /dev/null 2>&1; then
    echo "Node.js 已安装"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
        sudo apt-get install -y nodejs
        npm install pm2@latest -g
    fi
    
    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npmGit Graph
    fi
}

代理服务器安装() {
    install_dependencies
    # 创建代理目录
    rm -rf $CYSIC_AGENT_PATH
    mkdir -p $CYSIC_AGENT_PATH
    cd $CYSIC_AGENT_PATH

    # 下载代理服务器
    wget https://github.com/cysic-labs/aleo-miner/releases/download/v0.1.15/cysic-prover-agent-v0.1.15.tgz
    tar -xf cysic-prover-agent-v0.1.15.tgz
    cd cysic-prover-agent-v0.1.15

    AGENT_HOST=0.0.0.0:9000
    NOTIFY_HOST=notify.asia.aleopool.cysic.xyz:38883
    pm2 start "cysic-prover-agent -l $AGENT_HOST -notify $NOTIFY_HOST" --name "cysic-prover-agent"
    echo "代理服务器已启动。"
}

证明器安装() {
    install_dependencies
    # 创建证明器目录
    rm -rf $CYSIC_PROVER_PATH
    mkdir -p $CYSIC_PROVER_PATH
    cd $CYSIC_PROVER_PATH

    # 下载证明器
    wget https://github.com/cysic-labs/aleo-miner/releases/download/v0.1.17/cysic-aleo-prover-v0.1.17.tgz
    tar -xf cysic-aleo-prover-v0.1.17.tgz 
    cd cysic-aleo-prover-v0.1.17

    LocalHost=\`hostname -I|awk '{print \$1}'\`
    # 获取用户的奖励领取地址
    read -p $'(Aleo 地址钱包地址,可在 https://www.provable.tools/account 生成' Aleo_Address

    # 创建启动脚本
    cat <<EOF > cysic_prover_run.sh
#!/bin/bash
cd $CYSIC_PROVER_PATH/cysic-aleo-prover-v0.1.17
export LD_LIBRARY_PATH=./:\$LD_LIBRARY_PATH
./cysic-aleo-prover -l ./prover.log -a $LocalHost -w $Aleo_Address.$(curl -s ifconfig.me) -tls=true -p asia.aleopool.cysic.xyz:16699
EOF
    chmod +x cysic_prover_run.sh
    pm2 start cysic_prover_run.sh --name "cysic-aleo-prover"
    echo "证明器已安装并启动。"
}

options=(
代理服务器安装
证明器安装
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

