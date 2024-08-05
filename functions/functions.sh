#!/bin/bash

BIN_DIR=$(dirname "$0")
BIN_DIR=$(
    cd "$BIN_DIR" || exit 2
    pwd
)
ROOT_DIR=$(dirname "$BIN_DIR")
echo "B.sh: dirname \${BASH_SOURCE[0]} = $(dirname "${BASH_SOURCE[0]}")"
# shellcheck disable=SC1091
source "$ROOT_DIR/functions/common.sh"

# 寻找文件
find_file_by_name() {
    # find_file_by_name <dir> <file_name>

    if [ "$#" != 2 ]; then
        echo "Usage: $0 <dest> <file_name>" >&2
        exit 1
    fi
    target="$2"

    if [ ! -d "$1" ]; then
        echo "$1不是文件夹" >&2
        exit 1
    fi

    message=$(get_decorated_info "开始寻找，目标：$2, 搜索范围：$1")
    echo "$message"

    for f in $(find $1 -type f -name $target); do
        suffix=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$suffix: 找到文件 $f"
    done

    message=$(get_decorated_info "寻找完毕")
    echo "$message"

}

# 检查硬盘
check_disk() {
    # check_disK
    for disk in $(df -h | sed '1d' | grep -v 'tmfps' | awk '{print $NF}'); do
        echo "开始检测：$disk"
        if touch "$disk"/testfile && rm -f "$disk"/testfile; then
            echo "${disk}读写正常"
        else
            echo "${disk}读写有问题"
        fi
        echo
    done

}

# 检查HDFS
# 依赖：which hdfs
# 功能：检查HDFS是否正常运行
# 输出：如果HDFS正常运行，输出"HDFS is ready"；否则输出"HDFS is not ready"
# 示例：check_hdfs
check_hdfs() {
    set -e
    HDFS_RUN=$(which hdfs 2>/dev/null)
    if [ -z "$HDFS_RUN" ]; then
        echo "HDFS is not installed"
        exit 1
    fi

    hdfs_ready=$(hdfs dfsadmin -report | grep "Live datanodes" | awk '{print $3}')

    if [[ ${hdfs_ready} == "(1):" ]]; then
        echo "HDFS is ready"
    else
        echo "HDFS is not ready"
        exit 1
    fi
}

# 检查Hive
# 依赖：which hive
# 功能：检查Hive是否正常运行
# 输出：如果Hive正常运行，输出"Hive is ready"；否则输出"Hive is not ready"
# 示例：check_hive
check_hive() {
    set +e
    Hive_RUN=$(which hive 2>/dev/null)
    if [ -z "$Hive_RUN" ]; then
        echo "Hive is not installed"
        exit 1
    fi

    hive_ready=$(hive -e "show databases;" 2>&1)

    if [[ ${hive_ready} == *"FAILED"* ]]; then
        echo "Hive is not ready"
        exit 1
    else
        echo "Hive is ready"
    fi

}

check_hive
