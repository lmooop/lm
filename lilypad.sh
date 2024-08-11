#!/bin/bash
lilypad(){
  # 检查机器的架构并设置变量: $OSARCH
  #OSARCH=$(uname -m | awk '{if ($0 ~ /arm64|aarch64/) print "arm64"; else if ($0 ~ /x86_64|amd64/) print "amd64"; else print "unsupported_arch"}') && export OSARCH;
  # 检测您的操作系统并将其设置为: $OSNAME
  #OSNAME=$(uname -s | awk '{if ($1 == "Darwin") print "darwin"; else if ($1 == "Linux") print "linux"; else print "unsupported_os"}') && export OSNAME;
  # 下载最新发布版本的二进制
  # curl https://api.github.com/repos/lilypad-tech/lilypad/releases/latest | grep "browser_download_url.*lilypad-$OSNAME-$OSARCH" | cut -d : -f 2,3 | tr -d \" | wget -qi - -O lilypad
  wget -O lilypad https://github.com/Lilypad-Tech/lilypad/releases/download/v2.2.7/lilypad-linux-amd64-cpu
  # 更改权限
  chmod +x lilypad
  # 移动到bin目录
  sudo mv lilypad /usr/local/bin/lilypad
cat << EOF > /etc/systemd/system/lilypad-resource-provider.service
[Unit]
Description=Lilypad V2 Resource Provider GPU
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Environment="LOG_TYPE=json"
Environment="LOG_LEVEL=debug"
Environment="HOME=/app/lilypad"
Environment="OFFER_GPU=1"
EnvironmentFile=/app/lilypad/resource-provider-gpu.env
Restart=always
RestartSec=5s
ExecStart=/usr/local/bin/lilypad resource-provider 

[Install]
WantedBy=multi-user.target
EOF
}

gpu(){
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  
  sudo apt-get update -y
  
  sudo apt-get install -y nvidia-container-toolkit -y
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
}

bacalhau(){
  cd /tmp
  wget https://github.com/bacalhau-project/bacalhau/releases/download/v1.3.2/bacalhau_v1.3.2_linux_amd64.tar.gz -O bacalhau_v1.3.2_linux_amd64.tar.gz
  tar xfv bacalhau_v1.3.2_linux_amd64.tar.gz
  sudo mv bacalhau /usr/bin/bacalhau
  sudo mkdir -p /app/data/ipfs
  sudo chown -R $USER /app/data
cat << EOF > /etc/systemd/system/bacalhau.service
[Unit]
Description=Lilypad V2 Bacalhau
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Environment="LOG_TYPE=json"
Environment="LOG_LEVEL=debug"
Environment="HOME=/app/lilypad"
Environment="BACALHAU_SERVE_IPFS_PATH=/app/data/ipfs"
Restart=always
RestartSec=5s
ExecStart=/usr/bin/bacalhau serve --node-type compute,requester --peer none --private-internal-ipfs=false

[Install]
WantedBy=multi-user.target
EOF
}

ipfs(){
  cd /tmp
  wget https://github.com/ipfs/kubo/releases/download/v0.29.0/kubo_v0.29.0_linux-amd64.tar.gz -O kubo_v0.29.0_linux-amd64.tar.gz
  tar -zxvf kubo_v0.29.0_linux-amd64.tar.gz
  cd kubo/ 
  chmod +x ./ipfs
  ./install.sh
  export IPFS_PATH=/app/data/ipfs
  ipfs init
}

安装节点(){
  gpu && lilypad && bacalhau && ipfs && \
    read -p $'请输入已领水的EVM私钥: \n' wallet
  mkdir -pv /app/lilypad
cat << EOF > /app/lilypad/resource-provider-gpu.env
WEB3_PRIVATE_KEY=\${wallet}
EOF
sudo systemctl daemon-reload
sudo systemctl enable bacalhau
sudo systemctl enable lilypad-resource-provider
sudo systemctl start bacalhau
sudo systemctl start lilypad-resource-provider
sudo systemctl status lilypad-resource-provider
}
options=(
安装节点
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
