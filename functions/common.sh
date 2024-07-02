#!/bin/bash

# 打印带边框的消息
# Usage: get_decorated_info <info>
get_decorated_info() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <info>"
        exit 1
    fi
    message="$1"
    # 获取终端的宽度
    term_width=$(stty size | awk '{print $2}')
    # 计算消息的长度
    message_length=${#message}
    # 计算左右边距的长度
    padding_length=$(((term_width - message_length - 2) / 4))
    line=$(printf '%*s' "$padding_length" '' | tr ' ' '=')

    echo "${line} ${message} ${line}"
}

# 绑定java到JAVA_RUN
bind_java_run() {
    if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME"/bin/java ]; then
        JAVA_RUN="${JAVA_HOME}/bin/java"
    fi

    if [ -z "$JAVA_RUN" ] && [ "$(command -v java)" ]; then
        JAVA_RUN="java"
    fi

    if [ -z "$JAVA_RUN" ]; then
        echo "JAVA_HOME is not set" >&2
        exit 1
    fi
}

# 绑定hive到HIVE_RUN
bind_hive_run() {
    if [ -n "$HIVE_HOME" ] && [ -f "$HIVE_HOME"/bin/hive ]; then
        HIVE_RUN="${HIVE_HOME}/bin/hive"
    fi

    if [ -z "$HIVE_RUN" ] && [ "$(command -v hive)" ]; then
        HIVE_RUN="hive"
    fi

    if [ -z "$HIVE_RUN" ]; then
        echo "HIVE_HOME is not set" >&2
        exit 1
    fi
}

# 删除末尾特定字符
remove_trailing_chars() {
    # remove_trailing_chars <str> <remove_char>
    _string="$1"
    char_to_remove="$2"
    while [[ "${_string:(-1)}" == "$char_to_remove" ]]; do
        _string="${_string%"${_string:(-1)}"}"
    done
    echo "$_string"
}

# 删除开头特定字符
remove_start_char() {
    # remove_start_char <str> <remove_char>
    _string="$1"
    char_to_remove="$2"
    while [[ "$_string" == "$char_to_remove"* ]]; do
        _string="${_string#"$char_to_remove"}"
    done
    echo "${_string}"
}

# 打印所有系统变量
get_all_system_vars() {
    # get_all_system_vars
    for var_name in $(export | cut -d= -f1); do
        echo "$var_name"
    done
}
