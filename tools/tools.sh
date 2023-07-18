#!/usr/bin/env bash
#-------------------------------------------------
# 公共开发工具
# @author yeahoo2000@gmail.com
#-------------------------------------------------
if [ "" == "$ROOT" ]; then
    echo -e "\e[91m>>\e[0;0m 此脚本必须通过tools/dev.sh调用才能正常工作"
    exit 1
fi

# 生成配置文件模板
DOC[gen_cfg]="生成配置文件模板"
fun_gen_cfg(){
    local file=$ROOT/cfg.ini
    if [ -f $file ]; then
        read -p "[93m=> 配置文件已经存在，是否生成新文件并覆盖它？[0;0m[y/n]" choice
        if [[ $choice != "y" ]]; then
            exit 0
        fi
    fi
    cat > $file <<EOF
[default]
;=== 公共配置 ==========================================
; 游戏代号
GAME_CODE=mini.game

;=== 服务端配置(如不需要，无需理会) ==========================
; 域名
HOST=mini.game.local
; LUAJIT路径
LUAJIT=H:/soft/Win/luajit
; erl执行程序所在路径
ERL=erl
; werl执行程序所在路径
WERL=erl
; erl执行程序类型
ERL_TYPE=erl
; 节点前缀
NODE_PREFIX=dev_
; erlang节点通讯cookie
ERL_COOKIE=z5442c240b309fe2131d14
; erl节点间连接端口范围
ERL_PORT_MIN=40001
; erl节点间连接端口范围
ERL_PORT_MAX=44000
; erl文件编译参数
ERL_MAKE_PARAM="{d, dbg_tester}, {d, debug}, {d, disable_auth}, {d, enable_gm_cmd}"
; 是否远程编译
 IS_REMOTE=true
; 游戏节点对外端口偏移，例：如果设为8000，区号为10的节点端口为8000+10
PORT_OFFSET=8000
; 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASS=123456
; oms数据库名
OMS_DB_NAME="oms"
; Win的跟目录
WIN_ROOT=G:/data/mini.game.dev

; 如果在cygwin下工作请设置以下两个变量
; ROOT=G:/mini.game.dev
; DOCS="G:/mini.game.dev/docs/配置文件"

;=== AndroidApi相关配置(如不需要，无需理会) ==========================
; 项目ID
PROJECT_ID=AndroidApi
; 应用ID
APP_ID=com.shiyuegame.mini.game

;=== 客户端配置(如不需要，无需理会) ==========================
;unity安装目录
;UNITY=C:/Program\ Files\ \(x86\)/Unity/Editor/Unity.exe
UNITY=/Applications/Unity/Unity.app/Contents/MacOS/Unity
;应用名称
APP_NAME=mini.game
EOF

    INFO "已经生成配置文件: $file"
}

DOC[gen_base_setting]="生成base_setting配置文件模板"
fun_gen_base_setting(){
    local origin_base_setting=$ROOT/client/Assets/Resources/base_setting.txt
    local base_setting=$ROOT/base_setting.txt
    if [ -f $base_setting ]; then
        read -p "[93m=> 已经生成base_setting配置文件已经存在，是否生成新文件并覆盖它？[0;0m[y/n]" choice
        if [[ $choice != "y" ]]; then
            exit 0
        fi
    fi
    if [ -f $origin_base_setting ]; then
        cp -f $origin_base_setting $base_setting
        INFO "已经拷贝base_setting.txt文件: $base_setting"

        # read -p "[93m=> 是否删除${origin_base_setting}[0;0m[y/n]" choice2
        # if [[ $choice2 == "y" ]]; then
        #     rm -f $origin_base_setting
        #     local origin_base_setting_meta=$ROOT/client/Assets/Resources/base_setting.txt.meta
        #     if [ -f $origin_base_setting_meta ]; then
        #         rm -f $origin_base_setting_meta
        #     fi
        #     INFO "已经删除原base_setting.txt文件: $origin_base_setting"
        # fi
    else
    cat > $base_setting <<EOF
{
    "check_apk_path" : "http://127.0.0.1/mini_game_dev",
    "check_apk_path_ip" : "http://127.0.0.1/mini_game_dev",
    "debug" : "true",                       // 是否debug版本
    "apk_version" : "16111115",             // APK包版本号，用来强更
    "res_version" : "201608080808",         // 当前版本号这个值不要改
    "check_apk" : "false",                  // 是否检查强更
    "download_apk_path" : "http://127.0.0.1/mini_game_dev/apk", // apk下载地址
    "cdn_path" : "http://192.168.96.30/mini_game_dev",     //  cdn地址
    "theone_cdn_path" : "http://127.0.0.1/mini_game_dev",     //  一服cdn地址
    "url_of_language": "http://soar.res/reg/lang"
}
EOF
    INFO "已经生成base_setting.txt文件: $base_setting"
    fi
}

DOC[unity]="打开新的UnityEditor"
fun_unity(){
    check_unity_editor
    local path=$1
    if [[ "" != "$path" ]] && [[ ! -d $path ]]; then
        ERR "unity项目目录不存在: ${path}"
        exit 1
    fi
    if [ "" == "$path" ]; then
        ${UNITY} -projectPath ./ &
    else
        path=$(realpath $path)
        ${UNITY} -projectPath ${path} &
    fi
}

DOC[pull]="更新所有的源码仓库"
fun_pull(){
    for v in ${ROOT}/*; do
        if [ -d $v/.git ]; then
            echo ---------------------------------------------
            INFO "正在更新源码库: \e[92m$(basename $v)\e[0;0m"
            echo ---------------------------------------------
            cd $v && git pull
        elif [ -d $v/.svn ]; then
            echo ---------------------------------------------
            INFO "正在更新源码库: \e[92m$(basename $v)\e[0;0m"
            echo ---------------------------------------------
            cd $v && svn update
        fi
    done
}

DOC[allpull]="更新tools resources lua data 库"
fun_allpull(){
    INFO "源码库tools的状态信息:"
    #git pull --no-edit
    cd ${ROOT}/tools && git pull --no-edit
    INFO "源码库resources的状态信息:"
    cd ${ROOT}/resources && git pull --no-edit
    INFO "源码库lua的状态信息:"
    cd ${ROOT}/lua && git pull --no-edit
    if [ -d ${ROOT}/lua_combat ]; then
        INFO "源码库lua_combat的状态信息:"
        cd ${ROOT}/lua_combat && git pull --no-edit
    fi
    if [ -d ${ROOT}/lua_logic ]; then
        INFO "源码库lua_logic的状态信息:"
        cd ${ROOT}/lua_logic && git pull --no-edit
    fi
    INFO "源码库data的状态信息:"
    cd ${ROOT}/data && git pull --no-edit
}


DOC[status]="查看所有源码仓库的状态信息"
fun_status(){
    for v in ${ROOT}/*; do
        if [ -d $v/.git ]; then
            echo ---------------------------------------------
            INFO "源码库\e[92m$(basename $v)\e[0;0m的状态信息:"
            echo ---------------------------------------------
            cd $v && git status
        elif [ -d $v/.svn ]; then
            echo ---------------------------------------------
            INFO "源码库\e[92m$(basename $v)\e[0;0m的状态信息:"
            echo ---------------------------------------------
            cd $v && svn info
        fi
    done
}

DOC[make_logger]="编译Logger.dll文件"
fun_make_logger(){
    local path=${ROOT}/tools/dll_builder
    cd $path || exit 1
    INFO "正在编译Logger.dll文件..."
    mcs -define:UNITY_WEBPLAYER -r:/Applications/Unity/Unity.app/Contents/Frameworks/Managed/UnityEngine.dll -t:library Logger.cs
    INFO "编译完成: ${path}/Logger.dll"
}

DOC[gen_proto]="生成协议相关文件"
fun_gen_proto(){
    INFO "正在生成协议相关文件..."
    home=${ROOT}/tools/gen_proto

    # 处理服务端生成
    if [ -d ${ROOT}/server ]; then
        if [ ! -d $home ]; then
            ERR "协议配置目录不存在"
        fi
        cd ${home}
        mkdir -p ebin
        mkdir -p ${home}/cli
        $ERL -noshell -pa "${ROOT}/tools/ebin" -pa "./ebin" -eval "make:all()" -eval "gen_proto:compile(all)" -s c q
    fi
    if [ -d ${ROOT}/data/lua ]; then
        cp -f ${ROOT}/tools/gen_proto/cli/data_protocol.lua ${ROOT}/data/lua
        INFO "data_protocol.lua 更新成功"
    fi
}

DOC[make_proto_cfg]="编译协议模板文件"
fun_make_proto_cfg(){
    INFO "正在编译协议模板文件..."
    home=${ROOT}/tools/gen_proto

    # 处理服务端生成
    if [ -d ${ROOT}/server ]; then
        if [ ! -d $home ]; then
            ERR "协议配置目录不存在"
        fi
        cd ${home}
        mkdir -p ebin
        mkdir -p ${home}/cli
        $ERL -noshell -pa "${ROOT}/tools/ebin" -pa "./ebin" -eval "make:all()" -s c q
    fi
}

DOC[make_lua]="slua重新make"
fun_make_lua(){
    INFO "正在执行 slua重新make..."
    if [ -d ${ROOT}/client/Assets/Slua/LuaObject ]; then
        rm -rf ${ROOT}/client/Assets/Slua/LuaObject
    fi
    ${UNITY} -quit -batchmode -projectPath ${ROOT}/client -executeMethod SLua.LuaCodeGen.GenerateAll -logFile ${ROOT}/release/log_gen_lua.txt
    INFO "slua重新make 成功"
}
