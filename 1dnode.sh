#!/bin/bash

# 主菜单
function main_menu() {
    while true; do
        clear && logo
        echo "=============项目节点一键部署============"
        echo "请选择项目:"
        # echo "1. 0gAI 一键部署"
        # echo "3. Artela 一键部署"
        # echo "3. Rivalz 一键部署"
        echo "4. Network3 一键部署"
        echo "5. waku 一键部署"
        echo "-----------------------其他----------------------"
        echo "0. 退出脚本exit"
        read -p "请输入选项: " OPTION

        case $OPTION in
        
        # 1) wget -O 0g.sh https://raw.githubusercontent.com/lmooop/lm/main/0g.sh && chmod +x 0g.sh && ./0g.sh ;;
        # 2) wget -O Artela.sh https://raw.githubusercontent.com/lmooop/lm/main/Artela.sh && chmod +x Artela.sh && ./Artela.sh ;;
        # 3) wget -O rivalz.sh https://raw.githubusercontent.com/lmooop/lm/main/rivalz.sh && chmod +x rivalz.sh && ./rivalz.sh ;;
        4) wget -O network3.sh https://raw.githubusercontent.com/lmooop/lm/main/network3.sh && chmod +x network3.sh && ./network3.sh ;;
        5) wget -O waku.sh https://raw.githubusercontent.com/lmooop/lm/main/waku.sh && chmod +x waku.sh && ./waku.sh ;;
        
        0) echo "退出脚本。"; exit 0 ;;
        *) echo "无效选项，请重新输入。"; sleep 3 ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
}

logo()
{
echo -e '\033[33m      _  __        __    __  ___         __          \033[0m'
echo -e '\033[33m     / |/ /__  ___/ /__ /  |/  /__ ____ / /____ ____ \033[0m'    
echo -e '\033[33m    /    / _ \/ _  / -_) /|_/ / _ `(_-</ __/ -_) __/ \033[0m'    
echo -e '\033[33m   /_/|_/\___/\_,_/\__/_/  /_/\_,_/___/\__/\__/_/    \033[0m'
echo -e '\033[33m                                                     \033[0m'
}
# 显示主菜单
main_menu
