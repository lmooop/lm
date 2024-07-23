#!/bin/bash
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
node -v && \
npm i -g rivalz-node-cli@latest && \
rivalz run && \
pm2 start "rivalz run" --name rivalz && pm2 save && pm2 startup && \
pm2 list
