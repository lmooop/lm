#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 检查并安装 Node.js 和 npm
function install_nodejs_and_npm() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npm
    fi
}

# 检查并安装 PM2
function install_pm2() {
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}

# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="art"
    local shell_rc="$HOME/.bashrc"

    # 对于Zsh用户，使用.zshrc
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$shell_rc"; then
        echo "设置快捷键 '$alias_name' 到 $shell_rc"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$shell_rc"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $shell_rc' 来激活快捷键，或重新打开终端。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $shell_rc。"
        echo "如果快捷键不起作用，请尝试运行 'source $shell_rc' 或重新打开终端。"
    fi
}

# 节点安装功能
function install_node() {

    mkdir ~/art-back
    cp ~/.artelad/config/priv_validator_key.json ~/art1-back
    install_nodejs_and_npm
    install_pm2

    # 设置变量
    read -r -p "请输入你想设置的节点名称: " NODE_MONIKER
    export NODE_MONIKER=$NODE_MONIKER

    # 更新和安装必要的软件
    export DEBIAN_FRONTEND=noninteractive
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev lz4 snapd

    # 安装 Go
        sudo rm -rf /usr/local/go
        curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
        source $HOME/.bash_profile
        go version

    # 安装所有二进制文件
    cd $HOME
    git clone https://github.com/artela-network/artela
    cd artela
    git checkout main
    make install

    cd $HOME
    wget https://github.com/artela-network/artela/releases/download/v0.4.7-rc7-fix-execution/artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
    tar -xvf artelad_0.4.7_rc7_fix_execution_Linux_amd64.tar.gz
    mkdir libs
    mv $HOME/libaspect_wasm_instrument.so $HOME/libs/
    mv $HOME/artelad /usr/local/bin/
    echo 'export LD_LIBRARY_PATH=$HOME/libs:$LD_LIBRARY_PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=$HOME/libs:$LD_LIBRARY_PATH' >> /etc/profile
    source ~/.bashrc
    source /etc/profile

    # 配置artelad
    export LD_LIBRARY_PATH=$HOME/libs:$LD_LIBRARY_PATH
    artelad config chain-id artela_11822-1
    artelad init "$NODE_MONIKER" --chain-id artela_11822-1
    artelad config node tcp://localhost:3457

    # 获取初始文件和地址簿
    curl -L https://snapshots.dadunode.com/artela/genesis.json > $HOME/.artelad/config/genesis.json
    curl -L https://snapshots.dadunode.com/artela/addrbook.json > $HOME/.artelad/config/addrbook.json

    # 配置节点
    SEEDS=""
    #PEERS="ca8bce647088a12bc030971fbcce88ea7ffdac50@84.247.153.99:26656,a3501b87757ad6515d73e99c6d60987130b74185@85.239.235.104:3456,2c62fb73027022e0e4dcbdb5b54a9b9219c9b0c1@51.255.228.103:26687,fbe01325237dc6338c90ddee0134f3af0378141b@158.220.88.66:3456,fde2881b06a44246a893f37ecb710020e8b973d1@158.220.84.64:3456,12d057b98ecf7a24d0979c0fba2f341d28973005@116.202.162.188:10656,9e2fbfc4b32a1b013e53f3fc9b45638f4cddee36@47.254.66.177:26656,92d95c7133275573af25a2454283ebf26966b188@167.235.178.134:27856,2dd98f91eaea966b023edbc88aa23c7dfa1f733a@158.220.99.30:26680"
    PEERS="fbb6091ef6a449e8c99bb1b33c1394ca23903ba1@37.60.241.143:3456,2641bc6a25bb571feced1dcf60c13f1e40cae4aa@37.60.233.122:3456,7245766639add00db4f408b53e2358610081be64@37.60.233.120:3456,6fb0b193d96973cd6e25720b7d3b66258522921b@37.60.241.144:3456,aed9468ccd5c27264b67bffb92fa0705b4dfbf2c@109.123.254.228:3456,dab035e0b66a6ab6e7c6d61492d97e22179f3861@37.60.241.158:3456,10c3c128c7b3d81bde71da11d6953abf109434aa@37.60.241.159:3456,0505bef70a79bc2203385af8b7e4bfec46187719@147.124.211.111:3456,21d060db979b52952f165f0ec255c742034db792@147.182.224.179:26656,cc5697098c29267849ebd5d4ac66c12eb0d23cae@5.189.180.54:26656,66df5b61c9675143318eedd6b561388bb287a088@94.72.99.153:26656,8ef8348d9d0050851a73508f2a9abaf1fafdbd81@65.109.32.148:26176,ffadf2bd7ee89c32ef266a78285a4852431a5182@45.87.153.138:26656,652e28267fbe8ccc65b0493ed05c5431319672ca@62.169.29.71:3456,86969def3d834e8e959a768267d86b95c3c5e222@135.181.116.152:18656,8af94e1f7b08a403df85f7ff1abeb187c44b9f70@152.53.0.254:3456,27abd947b1d8264178f8c04958bd40fe257ba52b@156.67.82.186:3456,5fc781e7132b19c277924dc615d967a8eee83f07@213.199.53.39:3456,fcac9e0607f4427ea788ab2f1a5411ce02fa473d@65.108.200.59:3456,ab5a2a7a2a4ed9fd92c8c23af325a6ac31b24f5a@89.117.150.161:26656,f9076f84077e55bd55620419b3494ef624d1eff3@15.235.45.219:26656,d807d55d32a6d8de6f931fcb24d55004488a97f7@104.152.109.134:33656,1de876ca839c56055f8c934e93041cf6838f34e4@109.205.183.137:26656,b376b1eefd90dc98f19f015e739b57aeae0c5d7c@178.18.253.187:45656,fb7047dd0951a50a2be5c325a383910e52aa5bf9@185.87.21.107:28656,39dda2dcce693b3642c4b4119e8b3e5692223fbc@152.70.129.0:3456,b3211b205d2b2b08badffe806cc61a76e827a27f@178.128.127.160:33656,c95630c0f5ae897e9cd69bf20207771d8603721b@194.146.12.53:3456,496284a2de049a8eb92a250d0006d42a33993cfc@194.238.27.149:3456,dfda88777cbf1eba20089e9fad82f917e263fefe@135.125.67.241:26656,6a4f5e59db461264c992d703dd2bc09981ccc92a@84.247.143.162:3456,eb8325390adf264ae82dd77d550d3c2bb7718fef@152.42.180.181:3456,20d14cbf6349d7b8db363ab7346fe272302cae94@75.119.144.243:3456,26a8014f42bffddda0473a53b7cf23aada1023eb@84.247.166.118:3456,908fbf4551053622aa30a9871f9c4789dc316e7f@194.34.232.254:26656,f8d09c28488760222ccfd2b0573278cf07090f2c@38.242.198.48:26656,3687748566205a9d950cc532b949a235e732454d@64.44.171.213:3456,e562ad6b60ee28d6c99b1036a6d866720666a0ab@185.215.164.90:3456"
    sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.artelad/config/config.toml

    # 配置裁剪
    sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.artelad/config/app.toml
    sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.artelad/config/app.toml
    sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"0\"/" $HOME/.artelad/config/app.toml
    sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.artelad/config/app.toml
    sed -i -e 's/max_num_inbound_peers = 40/max_num_inbound_peers = 100/' -e 's/max_num_outbound_peers = 10/max_num_outbound_peers = 100/' $HOME/.artelad/config/config.toml

    # 配置端口
    node_address="tcp://localhost:3457"
    sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:3458\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:3457\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:3460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:3456\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":3466\"%" $HOME/.artelad/config/config.toml
    sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:3417\"%; s%^address = \":8080\"%address = \":3480\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:3490\"%; s%^address = \"localhost:9091\"%address = \"0.0.0.0:3491\"%; s%:8545%:3445%; s%:8546%:3446%; s%:6065%:3465%" $HOME/.artelad/config/app.toml
    echo "export Artela_RPC_PORT=$node_address" >> $HOME/.bash_profile
    source $HOME/.bash_profile   
    export LD_LIBRARY_PATH=$HOME/libs:$LD_LIBRARY_PATH
    pm2 start artelad -- start && pm2 save && pm2 startup
    
    # 下载快照
    artelad tendermint unsafe-reset-all --home $HOME/.artelad --keep-addr-book
    #wget -O artela-testnet_latest.tar.lz4 http://192.168.122.1:8099/artelad/artela-testnet_latest.tar.lz4
    #curl http://192.168.1.117:8099/artelad/artela-testnet_latest.tar.lz4 | lz4 -dc - | tar -xvf - -C $HOME/.artelad
    #curl https://snapshots-testnet.nodejumper.io/artela-testnet/artela-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.artelad
    curl https://a.lu-mao.org/api/public/dl/uPRx6Ik2/artelad/artela-testnet_latest.tar.lz4 | lz4 -dc - | tar -xvf - -C $HOME/.artelad
    #lz4 -c -d artela-testnet_latest.tar.lz4 | tar -xv -C $HOME/.artelad/data

    # 使用 PM2 启动节点进程
    cp -r ~/artback/priv_validator_key.json ~/.artelad/config
    export LD_LIBRARY_PATH=$HOME/libs:$LD_LIBRARY_PATH
    pm2 restart artelad

    echo '====================== 安装完成,请退出脚本后执行 source $HOME/.bash_profile 以加载环境变量 ==========================='
    
}

# 查看Artela 服务状态
function check_service_status() {
    pm2 list
}

# Artela 节点日志查询
function view_logs() {
    pm2 logs artelad
}

# 卸载节点功能
function uninstall_node() {
    echo "你确定要卸载Artela 节点程序吗？这将会删除所有相关的数据。[Y/N]"
    read -r -p "请确认: " response

    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载节点程序..."
	    mkdir -pv ~/artback/
	    mv ~/.artelad/config/priv_validator_key.json ~/artback/priv_validator_key.json
            pm2 stop artelad && pm2 delete artelad
            rm -rf $HOME/.artelad $HOME/artela $(which artelad)
            echo "节点程序卸载完成。"
            ;;
        *)
            echo "取消卸载操作。"
            ;;
    esac
}

# 创建钱包
function add_wallet() {
    artelad keys add wallet
}

# 导入钱包
function import_wallet() {
    artelad keys add wallet --recover
}

# 查询余额
function check_balances() {
    read -p "请输入钱包地址: " wallet_address
    artelad query bank balances "$wallet_address"
}

# 查看节点同步状态
function check_sync_status() {
    artelad status | jq .SyncInfo
}

# 创建验证者
function add_validator() {
    read -p "请输入您的钱包名称: " wallet_name
    read -p "请输入您想设置的验证者的名字: " validator_name
    
artelad tx staking create-validator \
--amount="1art" \
--pubkey=$(artelad tendermint show-validator) \
--moniker="$validator_name" \
--commission-rate="0.10" \
--commission-max-rate="0.20" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1" \
--gas="200000" \
--chain-id="artela_11822-1" \
--from="$wallet_name" \

}


# 给自己地址验证者质押
function delegate_self_validator() {
read -p "请输入质押代币数量: " math
read -p "请输入钱包名称: " wallet_name
artelad tx staking delegate $(artelad keys show $wallet_name --bech val -a)  ${math}art --from $wallet_name --chain-id=artela_11822-1 --gas=300000

}

# 导出验证者key
function export_priv_validator_key() {
    echo "====================请将下方所有内容备份到自己的记事本或者excel表格中记录==========================================="
    cat ~/.artelad/config/priv_validator_key.json
    
}


function update_script() {
    SCRIPT_URL="https://raw.githubusercontent.com/a3165458/Artela/main/Artela.sh"
    curl -o $SCRIPT_PATH $SCRIPT_URL
    chmod +x $SCRIPT_PATH
    echo "脚本已更新。请退出脚本后，执行bash Artela.sh 重新运行此脚本。"
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
        echo "============================Artela节点安装===================================="
        echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
        echo "节点社区 Discord 社群:https://discord.gg/GbMV5EcNWF"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装节点"
        echo "2. 创建钱包"
        echo "3. 导入钱包"
        echo "4. 查看钱包地址余额"
        echo "5. 查看节点同步状态"
        echo "6. 查看当前服务状态"
        echo "7. 运行日志查询"
        echo "8. 卸载节点"
        echo "9. 设置快捷键"  
        echo "10. 创建验证者"  
        echo "11. 给自己质押" 
        echo "12. 备份验证者私钥" 
        echo "13. 更新本脚本" 
        read -p "请输入选项（1-13）: " OPTION

        case $OPTION in
        1) install_node ;;
        2) add_wallet ;;
        3) import_wallet ;;
        4) check_balances ;;
        5) check_sync_status ;;
        6) check_service_status ;;
        7) view_logs ;;
        8) uninstall_node ;;
        9) check_and_set_alias ;;
        10) add_validator ;;
        11) delegate_self_validator ;;
        12) export_priv_validator_key ;;
        13) update_script ;;
        *) echo "无效选项。" ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
    
}

# 显示主菜单
main_menu
