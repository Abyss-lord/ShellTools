#!/bin/bash

ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$ROOT_DIR/common.sh"

close_hive_service_by_systemctl() {
    message=$(get_decorated_info "Try Use Systemctl To Stop Hiveserver2 And Hms Services")
    echo "$message"

    systemctl_dir="/usr/lib/systemd/system/"

    if [ ! -e "$systemctl_dir/hive-metastore.service" ]; then
        echo "can't find hive-metastore service"
        exit 1
    fi

    if [ ! -e "$systemctl_dir/hive-hiveserver2.service" ]; then
        echo "can't find hive-hiveserver2 service"
        exit 1
    fi

    if [ ! "$(command -v systemctl)" ]; then
        echo "systemctl command not found"
        exit 1
    fi

    # 停止服务
    systemctl stop hive-metastore
    systemctl stop hive-hiveserver2

    message=$(get_decorated_info "Use Systemctl To Stop Hiveserver2 And Hms Services Success")
    echo "$message"
}

# 启动Hive服务
start_hive_service_by_systemctl() {
    message=$(get_decorated_info "Try Use Systemctl To Start Hiveserver2 And Hms Services")
    echo "$message"
    systemctl_dir="/usr/lib/systemd/system/"

    if [ ! -e "$systemctl_dir/hive-metastore.service" ]; then
        echo "can't find hive-metastore service"
        exit 1
    fi

    if [ ! -e "$systemctl_dir/hive-hiveserver2.service" ]; then
        echo "can't find hive-hiveserver2 service"
        exit 1
    fi

    if [ ! "$(command -v systemctl)" ]; then
        echo "systemctl command not found"
        exit 1
    fi

    # 启动服务
    systemctl start hive-metastore
    systemctl start hive-hiveserver2

    message=$(get_decorated_info "Use Systemctl To Start Hiveserver2 And Hms Services Success")
    echo "$message"
}

# 关闭Hive服务
close_hive_service() {
    HIVE_METASTORE_DEFAULT_PORT=$1
    HIVE_HIVESERVER2_DEFAULT_PORT=$2

    metapid=$(check_process HiveMetastore "$HIVE_METASTORE_DEFAULT_PORT")
    [ "$metapid" != 0 ] && kill "$metapid" && echo "Metastroe服务已关闭" || echo "Metastore服务未启动"
    server2pid=$(check_process HiveServer2 "$HIVE_HIVESERVER2_DEFAULT_PORT")
    [ "$server2pid" != 0 ] && kill "$server2pid" && echo "HiveServer2服务已关闭" || echo "HiveServer2服务未启动"
}

check_process() {
    # 获取进程号并显示
    pid=$(ps -ef 2>/dev/null | grep -v grep | grep -i "$1" | awk '{print $2}')
    # ppid=$(netstat -anl 2>/dev/null | grep $2 | awk '{print $4}' | cut -d '.' -f 2)
    if [ "$pid" ]; then
        echo "$pid"
    else
        echo "0"
    fi
}
