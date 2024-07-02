#!/bin/bash
# 刷新kerberos票据
refresh_kerberos_principal() {
    # refresh_kerberos_principal <user> <keytab_dir>
    message=$(get_decorated_info "Start Authenticate!")
    echo "${message}"
    kerberos_name="$1"
    keytabs_dir="$2"
    if [ -z "$keytabs_dir" ]; then
        keytabs_dir="/etc/security/keytabs"
    fi

    principal=$(klist -kt "${keytabs_dir}"/"${kerberos_name}".keytab | grep "${kerberos_name}"/ | awk '{print $4}' | tail -n 1)
    echo "Use Principal = ${principal}"
    if [ -z "$principal" ]; then
        echo "principal is empty"
        exit 126
    fi
    kinit -kt "${keytabs_dir}"/"${kerberos_name}".keytab "${principal}"

    message=$(get_decorated_info "Success Authenticate!")
    echo "${message}"
}
