#!/bin/sh

set -e

HIVE_LOG_DIR=$LOG_HOME/hive

init_log() {
    if [ ! -d ${HIVE_LOG_DIR} ]; then
        mkdir -v -p $HIVE_LOG_DIR
    fi
}

# 检查进程是否运行正常，参数1为进程名，参数2为进程端口
check_process() {
    pid=$(ps -ef 2>/dev/null | grep -v grep | grep -i $1 | awk '{print $2}')
    # ppid=$(netstat -anl 2>/dev/null | grep $2 | awk '{print $4}' | cut -d '.' -f 2)
    if [ "$pid" ]; then
        echo "$pid"
    else
        echo "0"
    fi
}

hive_start() {
    if [ ! -n "${HIVE_HOME}" ]; then
        echo "HIVE_HOME is not set!!" >&2
        exit 1
    fi

    metapid=$(check_process HiveMetastore 9083)
    cmd="nohup $HIVE_HOME/bin/hive --service metastore >$HIVE_LOG_DIR/metastore.log 2>&1 &"
    cmd=$cmd" sleep 4; hdfs dfsadmin -safemode wait >/dev/null 2>&1"
    [ ! "$metapid" -ne "0" ] && eval $cmd && echo "MetaStore成功启动" || echo "Metastroe服务已启动"
    server2pid=$(check_process HiveServer2 10000)
    cmd="nohup $HIVE_HOME/bin/hive --service hiveserver2 >$HIVE_LOG_DIR/hiveServer2.log 2>&1 &"
    [ ! "$server2pid" -ne "0" ] && eval $cmd && echo "HiveServer2成功启动" || echo "HiveServer2服务已启动"
}

hive_stop() {
    metapid=$(check_process HiveMetastore 9083)
    [ "$metapid" -ne "0" ] && kill $metapid && echo "Metastroe服务已关闭" || echo "Metastore服务未启动"
    server2pid=$(check_process HiveServer2 10000)
    [ "$server2pid" -ne "0" ] && kill $server2pid && echo "HiveServer2服务已关闭" || echo "HiveServer2服务未启动"
}

show_status() {
    if [ "$2" -ne "0" ]; then
        echo "$1服务运行正常, 进程号: $2"
    else
        echo "$1服务运行异常, 进程号: $2"
    fi
}

# 主函数
case $1 in
"start")
    hive_start
    ;;
"stop")
    hive_stop
    ;;
"restart")
    hive_stop
    sleep 2
    hive_start
    ;;
"status")
    result=$(check_process HiveMetastore 9083)
    show_status HiveMetastore "$result"
    result=$(check_process HiveServer2 10000)
    show_status HiveServer2 "$result"
    ;;
*)
    echo Invalid Args!
    echo "Usage: $0 start|stop|restart|status" >&2
    ;;
esac
