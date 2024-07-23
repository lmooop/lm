#!/bin/bash

# 主菜单
function main_menu() {
    while true; do
        clear
        echo "=============项目节点一键部署============"
        echo "请选择项目:"
        echo "1. 0gAI 一键部署"
        echo "2. Artela 一键部署"
        echo "3. Rivalz 一键部署"
        echo "-----------------------其他----------------------"
        echo "0. 退出脚本exit"
        read -p "请输入选项: " OPTION

        case $OPTION in
        
        1) wget -O 0g.sh https://raw.githubusercontent.com/lmooop/lm/main/0g.sh && chmod +x 0g.sh && ./0g.sh ;;
        2) wget -O Artela.sh https://raw.githubusercontent.com/lmooop/lm/main/Artela.sh && chmod +x Artela.sh && ./Artela.sh ;;
        3) wget -O rivalz.sh https://raw.githubusercontent.com/lmooop/lm/main/rivalz.sh && chmod +x rivalz.sh && ./rivalz.sh ;;
        
        0) echo "退出脚本。"; exit 0 ;;
        *) echo "无效选项，请重新输入。"; sleep 3 ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 显示主菜单
main_menu
