#!/usr/bin/env bash
#-------------------------------------------------
# 资源库相关开发工具
# @author yeahoo2000@gmail.com
#-------------------------------------------------
if [ "" == "$ROOT" ]; then
    echo -e "\e[91m>>\e[0;0m 此脚本必须通过tools/dev.sh调用才能正常工作"
    exit 1
fi

PLATFORM=( "pc" "android" "ios" )

# 检查平台参数是否正确
check_platform(){
    if [[ "" == $1 ]]; then
        IFS=$' ' && ERR "请传入平台标识，有效值: ${PLATFORM[*]}"
        exit 1
    fi
    if ! in_array PLATFORM[@] $1; then
        IFS=$' ' && ERR "不支持的平台${1}，有效值: ${PLATFORM[*]}"
        exit 1
    fi
}

DOC[make_resources]="编译资源库"
fun_make_resources(){
    local platform=$1
    local lock_name=make_res_$platform
    check_platform $platform

    if [[ "pc" == $platform ]]; then
        local res=${ROOT}/resources
    else
        local res=${ROOT}/resources_${platform}
    fi

    if [[ ! -d $res ]]; then
        ERR "因为unity切换平台比较耗时，所以请将resources复制一份到同级目录，并命名为resources_${platform}，这样可以省去平台切换的时间(第一次执行仍然会比较耗时，但之后就会快很多了)"
        lock_release $lock_name
        exit 1
    fi

    lock_check $lock_name "编译GameResources资源文件"
    # logfile=/dev/stdout
    # if $(in_cygwin); then
        logfile=${ROOT}/release/build_log.text
        INFO "日志保存在 ${logfile} 文件中"
    # fi

    # wsl下执行需要调整部分参数
    local unity_logfile=${logfile}
    if $(in_wsl); then
        INFO "当前是wsl模式"
        res=${WIN_ROOT}/resources
        unity_logfile=${WIN_ROOT}/release/build_log.text
    fi

    INFO "正在编译 ${platform} 平台的资源库，路径: $res ..."
    $UNITY -batchmode -projectPath $res -executeMethod EditorTools.Patch.AssetPatchMaker.MakePatchCmd -CustomArgs:BuildTarget=${platform} -quit -nographics -logFile ${unity_logfile}
    cat ${logfile}
    lock_release $lock_name

    INFO "编译 ${platform} 平台的资源库完成"
}

DOC[make_resources_data]="编译资源数据"
fun_make_resources_data(){
    local platform=$1
    local lock_name=make_res_$platform
    check_platform $platform

    if [[ "pc" == $platform ]]; then
        local res=${ROOT}/resources
    else
        local res=${ROOT}/resources_${platform}
    fi

    if [[ ! -d $res ]]; then
        ERR "因为unity切换平台比较耗时，所以请将resources复制一份到同级目录，并命名为resources_${platform}，这样可以省去平台切换的时间(第一次执行仍然会比较耗时，但之后就会快很多了)"
        lock_release $lock_name
        exit 1
    fi

    lock_check $lock_name "编译GameResources资源文件"
    logfile=${ROOT}/release/build_log.text
    INFO "日志保存在 ${logfile} 文件中"

    # wsl下执行需要调整部分参数
    local unity_logfile=${logfile}
    if $(in_wsl); then
        INFO "当前是wsl模式"
        res=${WIN_ROOT}/resources
        unity_logfile=${WIN_ROOT}/release/build_log.text
    fi

    INFO "正在编译 ${platform} 平台的资源库，路径: $res ..."
    $UNITY -batchmode -projectPath $res -executeMethod AssetBundleTools.MakeDataOnly -CustomArgs:BuildTarget=${platform} -quit -nographics -logFile ${unity_logfile}
    cat ${logfile}
    lock_release $lock_name

    INFO "编译 ${platform} 平台的资源数据完成"
}

DOC[make_clzmapping]="生成clz_mapping"
fun_make_clzmapping(){
    local platform=$1
    local pathTmp=${ROOT/:\//_}
    local resFullPath=${pathTmp//\//_}
    local lock_name=make_${resFullPath}_res_${platform}
    check_platform $platform

    if [[ "pc" == $platform || "mac" == $platform ]]; then
        local res=${ROOT}/resources
    else
        local res=${ROOT}/resources_${platform}
    fi

    if [[ ! -d $res ]]; then
        ERR "因为unity切换平台比较耗时，所以请将resources复制一份到同级目录，并命名为resources_${platform}，这样可以省去平台切换的时间(第一次执行仍然会比较耗时，但之后就会快很多了)"
        lock_release $lock_name
        exit 1
    fi

    lock_check $lock_name "生成clz_mapping"
    logfile=${ROOT}/release/build_log.text
    INFO "日志保存在 ${logfile} 文件中"

    # wsl下执行需要调整部分参数
    local unity_logfile=${logfile}
    if $(in_wsl); then
        INFO "当前是wsl模式"
        res=${WIN_ROOT}/resources
        unity_logfile=${WIN_ROOT}/release/build_log.text
    fi

    INFO "生成clz_mapping，路径: $res ..."

    $UNITY -batchmode -projectPath $res -executeMethod EditorTools.Patch.AssetPatchMaker.MakeClzMappingCmd -CustomArgs:BuildTarget=${platform} -quit -nographics -logFile ${unity_logfile}
    cat ${logfile}
    lock_release $lock_name

    INFO "生成clz_mapping完成"
}

DOC[clean_release]="清空release下已经编译的资源文件"
fun_clean_release(){
    read -p "[93m=> 清空后需要比较长的重新编译时间，是否继续？[0;0m[y/n]" choice
    if [[ $choice != y ]]; then
        exit 0
    fi
    rm -rf ${ROOT}/release/pc
    rm -rf ${ROOT}/release/android
    rm -rf ${ROOT}/release/ios
    INFO "已清空release目录"
}
