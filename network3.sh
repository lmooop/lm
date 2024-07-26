#!/bin/bash
install ()
{
  sudo apt install net-tools -yyq && \
  wget -O ubuntu-node-v2.1.0.tar https://network3.io/ubuntu-node-v2.1.0.tar && \
  cd ~/ubuntu-node && \
  ./manager.sh up && \
  echo -e "\033[31m 请复制44 个字节的私钥 \033[0m" && \
  ./manager.sh key
  
}
check ()
{
  cat > ~/network3_check.sh<<EOF
  #!/bin/bash
  run=$(ss -tlunp|grep "8080"|wc -l)
  if [ ${run} == 0 ];then 
      cd /root/ubuntu-node && ./manager.sh up
  fi
  EOF
  chmod +x ~/network3_check.sh
  (crontab -l;echo "*/2 * * * * bash ~/network3_check.sh") | crontab
}

install && \
check
