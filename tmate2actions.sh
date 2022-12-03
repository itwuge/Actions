#!/bin/bash
# 版权所有 (c) 2022 itwuge
# 这是免费软件，根据MIT许可证许可。
# 有关详细信息，请参阅/LICENSE。
# https://github.com/itwuge/tmate2actions
# 文件名：tmate2actions.sh
# 描述：使用tmate通过SSH连接到Github Actions VM
# 版本：1.0
# 设置环境变量
set -e
# 给消息设置一些默认样式
Green_color="\033[32m"
Red_color="\033[31m"
Default_color="\033[0m"
# 定义正确和错误消息变量
INFO="[${Green_color}INFO${Default_color}]"
ERROR="[${Red_color}ERROR${Default_color}]"
# 指定 sock 启动文件
SOCK="/tmp/tmate.sock"
# 指定一个没有的目录如果存在就退出shell
OUT_FILE="/tmp/logout"

# 代码开始
# --------------------------------------------------
# 判断是什么系统安装tmate 
if [[ -n "$(uname | grep Linux)" ]];then
	curl -fsSL git.io/tmate.sh | bash
elif [[ -x "$(command -v brew)" ]];then
	brew install tmate
else
	echo -e "${ERROR} 不支持此系统!!!!"
	exit 1
fi

# 生成ssh密钥
[[ -e ~/.ssh/id_rsa ]] || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

# 监控 tmate 运行状态
echo -e "${INFO}       ${Red_color}tmate 准备中请等待........"
tmate -S ${SOCK} new-session -d
tmate -S ${SOCK} wait tmate-ready

# 打印连接信息
T_SSH=$(tmate -S ${SOCK} display -p '#{tmate_ssh}')
T_WEB=$(tmate -S ${SOCK} display -p '#{tmate_web}')

# 打印消息阻止跳转
while ((${TIMES_COUNT:=1} <= ${TIMES_TOTAL:=3})); do
    # 控制内循环变量
    CONTROL_TIME=${INTERVAL_TIME:=3}
    while ((${TIMES_COUNT} > 0)) && ((${CONTROL_TIME} > 0)); do
    	# 显示 
        echo -e "${INFO} (${TIMES_COUNT}/${TIMES_TOTAL}) ${Red_color}正在准备连接地址,请稍等!!!... ${Default_color}${CONTROL_TIME}S "
        # 相隔 1秒 执行一次
        sleep 1
        CONTROL_TIME=$((${CONTROL_TIME} - 1))
    done
    echo "-----------------------------------------------------------"
    echo -e "${Red_color}            复制并粘贴以下内容到终端或浏览器中${Default_color}"
    echo -e "${Red_color}       使用 ${Green_color}           Ctrl+C             ${Red_color}连接到此会话${Default_color}"
    echo -e "${Red_color}       使用 ${Green_color}cd openwrt && make menuconfig ${Red_color}进入定制页面${Default_color}"
    echo -e "${Red_color}SSH 终端连接: ${Green_color}${T_SSH}${Default_color}"
    echo -e "${Red_color}WEB 连接地址: ${Green_color}${T_WEB}${Default_color}"
#   echo -e "R_SHH 连接地址:  ${Red_color} ${R_SHH} ${Default_color}"
#   echo -e "R_WEB 连接地址:  ${Red_color} ${R_WEB} ${Default_color}"
    echo -e "${Red_color}温 馨 提 示 : ${Green_color}运行 'touch ${OUT_FILE}'${Red_color} 或 ${Green_color}运行 exit ${Red_color}继续下一步.${Default_color}"
    echo "-----------------------------------------------------------"
    TIMES_COUNT=$((${TIMES_COUNT} + 1))
done
while [[ -S  ${SOCK} ]]; do
    sleep 1
    if [[ -e ${OUT_FILE} ]]; then
    	# 删除 tmate 进程
    	tmate -S ${SOCK} kill-session
        echo -e "${INFO} 继续下一步."
        exit 0
    fi
done
# ref: https://github.com/csexton/debugger-action/blob/master/script.sh
