#!/bin/bash
MINICONDA_PATH="$HOME/miniconda"
CONDA_EXECUTABLE="$MINICONDA_PATH/bin/conda"


安装验证节点() {
    install_conda
    ensure_conda_initialized
    install_nodejs_and_npm
    install_pm2
    apt update && apt upgrade -y
    apt install curl sudo python3-venv iptables build-essential wget jq make gcc nano npm -y
    git clone https://github.com/FLock-io/llm-loss-validator.git
    # 进入项目目录
    cd llm-loss-validator
    export PATH="$HOME/miniconda/bin:$PATH"
    # 创建并激活conda环境
    conda create -n llm-loss-validator python==3.10 -y
    source "$MINICONDA_PATH/bin/activate" llm-loss-validator
    # 安装依赖
    pip install -r requirements.txt
    read -p $'Hugging Face API: \n' HF_TOKEN
    read -p $'Flock APi: \n' FLOCK_API_KEY
    read -p $'Task ID: \n' TASK_ID
    # 克隆仓库
    # 获取当前目录的绝对路径
    SCRIPT_DIR="$(pwd)"
    # 创建启动脚本
    cat << EOF > run_validator.sh
#!/bin/bash
source "$MINICONDA_PATH/bin/activate" llm-loss-validator
cd $SCRIPT_DIR/src
CUDA_VISIBLE_DEVICES=0 \
bash start.sh \
--hf_token "$HF_TOKEN" \
--flock_api_key "$FLOCK_API_KEY" \
--task_id "$TASK_ID" \
--validation_args_file validation_config.json.example \
--auto_clean_cache False
EOF
    chmod +x run_validator.sh
    pm2 start run_validator.sh --name "flock-validator" && pm2 startup&& pm2 save
    echo "Flock节点安装成功....."
}



ensure_conda_initialized() {
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
    fi
    # if [ -f "$CONDA_EXECUTABLE" ]; then
    #     eval "$("$CONDA_EXECUTABLE" shell.bash hook)"
    # fi
}

function install_conda() {
    if [ -f "$CONDA_EXECUTABLE" ]; then
        echo "Conda 已安装在 $MINICONDA_PATH"
        ensure_conda_initialized
    else
        echo "Conda 未安装，正在安装..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
        bash miniconda.sh -b -p $MINICONDA_PATH
        rm miniconda.sh
        
        # 初始化 conda
        "$CONDA_EXECUTABLE" init
        ensure_conda_initialized
        
        echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
    fi
    
    # 验证 conda 是否可用
    if command -v conda &> /dev/null; then
        echo "Conda 安装成功，版本: $(conda --version)"
    else
        echo "Conda 安装可能成功，但无法在当前会话中使用。"
        echo "请在脚本执行完成后，重新登录或运行 'source ~/.bashrc' 来激活 Conda。"
    fi
}

# 检查并安装 Node.js 和 npm
function install_nodejs_and_npm() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装，版本: $(node -v)"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装，版本: $(npm -v)"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npm
    fi
}

# 检查并安装 PM2
function install_pm2() {
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装，版本: $(pm2 -v)"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}

卸载验证节点() {
    pm2 delete flock-validator && rm -rf llm-loss-validator
}

安装Training节点(){
  install_conda
  ensure_conda_initialized
  install_nodejs_and_npm
  install_pm2
  apt update && apt upgrade -y
  apt install curl sudo python3-venv iptables build-essential wget jq make gcc nano npm -y
  git clone https://github.com/FLock-io/testnet-training-node-quickstart.git
  cd testnet-training-node-quickstart
  conda create -n training-node python==3.10
  # source "$MINICONDA_PATH/bin/activate" training-node
  conda activate training-node
  pip install -r requirements.txt
  read -p $'Hugging Face API: \n' HF_TOKEN
  read -p $'Flock APi: \n' FLOCK_API_KEY
  read -p $'Task ID: \n' TASK_ID
  read -p $'Hugging用户吗: \n' HF_USERNAME
  read -p $'GPU 数量: \n' G_num
  # 克隆仓库
  # 获取当前目录的绝对路径
  SCRIPT_DIR="$(pwd)"
  genv=0
  for ((i=1; i<${G_num}; i ++))
  do
    genv=${genv},$i
  done

   # 创建启动脚本
cat << EOF > run_training.sh
#!/bin/bash
source "$MINICONDA_PATH/bin/activate" training-node
cd $SCRIPT_DIR/src
TASK_ID=${TASK_ID} FLOCK_API_KEY="${FLOCK_API_KEY}" HF_TOKEN="${HF_TOKEN}" CUDA_VISIBLE_DEVICES=${genv} HF_USERNAME="${HF_USERNAME}" python full_automation.py
EOF
  chmod +x ./run_training.sh
  pm2 start run_training.sh --name "flock-training" && pm2 startup && pm2 save
  pm2 logs flock-training
}

添加定时任务检测版本更新(){
cat > ~/flock-check.sh << EOF
#!/bin/bash
cd ~/llm-loss-validator && git pull && pm2 restart flock-validator
cd ~/testnet-training-node-quickstart && git pull && pm2 restart flock-training
EOF
  exist=$(crontab -l|grep -E "flock-check")        
  if [ ! "$exist" ] ; then 
    chmod +x ~/flock-check.sh
    (crontab -l;echo "* */4 * * * bash ~/flock-check.sh") | crontab
  fi
  crontab -l
}

options=(
安装验证节点
卸载验证节点
安装Training节点
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
