#!/bin/bash

BIN_DIR=$(dirname "$0")
BIN_DIR=$(
    cd "$BIN_DIR" || exit
    pwd
)
. "${BIN_DIR}/common.sh"

# 刷新kerberos票据
# refresh_kerberos_principal <user> [keytab_dir]
refresh_kerberos_principal() {

    if [ $# -lt 1 ]; then
        echo "Usage: refresh_kerberos_principal <user> [keytab_dir]"
        exit 1
    fi

    user_name="$1"

    if [ "$#" -gt 1 ]; then
        keytabs_dir="$2"
    fi

    keytabs_dir="${keytabs_dir:-/etc/security/keytabs}"

    if [ -d "$keytabs_dir" ]; then
        error_logging "keytabs_dir is empty"
        exit 126
    fi

    # 开始认证
    message=$(get_decorated_info "Start Authenticate!")
    echo "${message}"

    principal=$(klist -kt "${keytabs_dir}"/"${user_name}".keytab | grep "${user_name}"/ | awk '{print $4}' | tail -n 1)
    echo "Use Principal = ${principal}"
    if [ -z "$principal" ]; then
        error_logging "principal is empty"
        exit 126
    fi
    # 刷新票据
    kinit -kt "${keytabs_dir}"/"${user_name}".keytab "${principal}"

    message=$(get_decorated_info "Success Authenticate!")
    echo "${message}"
}
