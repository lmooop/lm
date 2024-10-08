#!/bin/bash
安装rivalz()
{
    exist=$(pm2 list|grep -E "rivalz")
    if [ "$exist" ] ; then 
      echo "rivalz已经在运行，退出安装....."
      rivalz update-version
      return 0
    fi

  if command -v node > /dev/null 2>&1; then
      echo "Node.js 已安装"
      npm i pm2@latest -g
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

  node -v && npm i -g rivalz-node-cli@latest && rivalz update-version && \
    rivalz run && pm2 start "rivalz run" --name rivalz && \
    pm2 startup && pm2 save && pm2 list
  echo "rivalz安装成功..."
}

卸载rivalz(){
  pm2 del rivalz
  pm2 save
  rm -rf ~/.rivalz
  echo "卸载完成"
}

添加定时任务检测版本更新(){
cat > ~/rivalz_update.sh << EOF
#!/bin/bash
npm i -g rivalz-node-cli@latest && pm2 restart rivalz
EOF
  exist=$(crontab -l|grep -E "rivalz_update")        
  if [ ! "$exist" ] ; then 
    chmod +x ~/rivalz_update.sh
    (crontab -l;echo "0 */4 * * * bash ~/rivalz_update.sh") | crontab
  fi
  crontab -l
}
options=(
安装rivalz
卸载rivalz
添加定时任务检测版本更新
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
