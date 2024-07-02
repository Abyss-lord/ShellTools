#!/bin/sh
# 用法：[BACKUP_PATH] [UPDATE_JAR_PATH]
# BACKUP_PATH:JAR 包备份路径
# UPDATE_JAR_PATH 需要更新的JAR包目录
# ！备份会将整个HIVE LIB备份，因此更新的话是整个LIB目录
set -e
# --------------- 定义环境变量 -------------------------
# 当前时间
CUR_TIME=$(date "+%Y%m%d")
# 备份后缀
BAK_END="_bak_${CUR_TIME}"
# 备份路径
DEFAULT_BACKUP_PATH=/tmp/backup_jar/${CUR_TIME}
# HIVE_HOME
HIVE_HOME_PATH=${HIVE_HOME}
# HIVE LIB
HIVE_LIB_HOME="${HIVE_HOME_PATH}/lib"
# 更新JAR包目录
DEFAULT_UPDATE_JAR_PATH=/tmp/jars
DEFAULT_PERMISSIONS=755

# hcatalog_jar="${HIVE_HOME}/hcatalog/share/hcatalog/hive-hcatalog-streaming-3.1.2.jar"
# -------------------------------------------------

# ------------------- 定义函数 -------------------------
is_dir() {
    input_path=$1
    if [ ! -d "${input_path}" ]; then
        echo "input_path is not a dir, current path: ${input_path}" >&2
        exit 1
    fi
}

# 创建备份文件夹
create_dir() {
    if [ ! -d "$1" ]; then
        sudo mkdir -p "$1"
    fi
}

# 备份Jar包
backup_jars() {
    echo "======================= start backup ======================="
    for jar_path in "${HIVE_LIB_HOME}"/*.jar; do
        file_name=$(basename "$jar_path")
        echo "${jar_path} -> ${BACKUP_PATH}/${file_name}${BAK_END}"
        sudo mv "${jar_path}" "${BACKUP_PATH}/${jar_name}${BAK_END}"

    done
    echo "======================= finish backup ======================="
}

# 更新JAR包
update_jars() {
    echo "======================= start copy ======================="
    for file in "${UPDATE_JAR_PATH}"/*.jar; do
        sudo cp -v "${file}" "${HIVE_LIB_HOME}/"
    done
    echo "======================= finish copy ======================="
}

# 授权单个文件
authorize_file() {
    file_path=$1
    echo "authorize ${DEFAULT_PERMISSIONS} to ${file_path}"
    sudo chmod "${DEFAULT_PERMISSIONS}" "${file_path}"
}

# 授权整个HIVE-LIB
authorize_hive_lib_files() {
    DEFAULT_DIR_PATH="${HIVE_LIB_HOME}"
    echo "======================= start authroize ======================="
    for file in "${DEFAULT_DIR_PATH}"/*.jar; do
        authorize_file "${file}"
    done
    echo "======================= finish authroize ======================="
}

remove_start_char() {
    symbol='/'
    if [ "$#" -gt 1 ]; then
        symbol=$2
    fi
    _string="$1"
    while [[ "$_string" == "$symbol"* ]]; do
        _string="${_string#"${symbol}"}"
    done
    echo "${_string}"
}

remove_end_char() {
    symbol='/'
    if [ "$#" -gt 1 ]; then
        symbol=$2
    fi
    _string="$1"
    while [[ "${_string}" == *"${symbol}" ]]; do
        _string="${_string%"${symbol}"}"
    done
    echo "${_string}"
}

main() {
    backup_jars
    update_jars
    authorize_hive_lib_files
}
# -----------------------------------------------------

# --------------- 参数输入 -------------------------

if [ "$#" -eq 0 ]; then
    BACKUP_PATH=${DEFAULT_BACKUP_PATH}
    UPDATE_JAR_PATH=${DEFAULT_UPDATE_JAR_PATH}
fi

if [ "$#" -gt 0 ]; then
    BACKUP_PATH=$1
fi

if [ "$#" -gt 1 ]; then
    UPDATE_JAR_PATH=$2
fi

# -------------------------------------------------

# ----------------- 安全性检查 -----------------------
# 检查HIVE_HOME是否存在
if [ -z "${HIVE_HOME_PATH}" ]; then
    echo "HIVE_HOME 不存在" >&2
    exit 1
fi

if [ ! "${BACKUP_PATH}" = "${DEFAULT_BACKUP_PATH}" ]; then
    is_dir "${BACKUP_PATH}"
else
    create_dir "${BACKUP_PATH}"
fi

if [ ! "${UPDATE_JAR_PATH}" = ${DEFAULT_UPDATE_JAR_PATH} ]; then
    is_dir "${UPDATE_JAR_PATH}"
fi

is_dir "${UPDATE_JAR_PATH}"

BACKUP_PATH=$(remove_end_char "${BACKUP_PATH}" "/")
UPDATE_JAR_PATH=$(remove_end_char "${UPDATE_JAR_PATH}" "/")

# --------------------------------------------------

main
