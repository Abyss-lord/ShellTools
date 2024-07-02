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
