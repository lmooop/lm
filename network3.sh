#!/bin/bash
安装()
{

  exist=$(ss -tlunp|grep -E "8080")        
  if [ "$exist" ] ; then 
    echo "network3已在运行,退出安装..."
    return 0
  fi

  cd ~
  sudo apt install net-tools -yyq && \
  wget -O ubuntu-node-v2.1.0.tar https://network3.io/ubuntu-node-v2.1.0.tar && \
  tar -xf ~/ubuntu-node-v2.1.0.tar && \
  cd ~/ubuntu-node && \
  ./manager.sh up && \
  echo -e "\033[31m 请复制44 个字节的私钥 \033[0m" && \
  ./manager.sh key && \
  ip=$(curl ipinfo.io/ip) && \
  echo -e "\033[31m 打开链接 \033[0m" && \
  echo "https://account.network3.ai/main?o=$ip:8080"
}

添加检测脚本()
{
  cat > ~/network3_check.sh<<EOF
#!/bin/bash
run=\$(ss -tlunp|grep "8080"|wc -l)
if [ \${run} == 0 ];then 
    cd /root/ubuntu-node && ./manager.sh up
fi
EOF
  exist=$(crontab -l|grep -E "network3_check")        
  if [ ! "$exist" ] ; then 
    chmod +x ~/network3_check.sh
    (crontab -l;echo "*/2 * * * * bash ~/network3_check.sh") | crontab
  fi
  crontab -l
}

卸载节点(){
  cd ~/ubuntu-node && ./manager.sh down
  rm -rf ~/ubuntu-node.*
  rm -rf ~/network3_check.sh
}

options=(
安装
添加检测脚本
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
  logo
  PS3="请输入编号: "
  # logo
  select p in ${options[@]}
  do
    $p
    break;
  done
}
menu
