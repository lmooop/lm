#!/bin/bash
sudo apt install net-tools -yyq && \
wget -O ubuntu-node-v2.1.0.tar https://network3.io/ubuntu-node-v2.1.0.tar && \
cd ~/ubuntu-node && \
./manager.sh up && \
echo -e "\033[31m 请复制44 个字节的私钥 \033[0m" && \
./manager.sh key
