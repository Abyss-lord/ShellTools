#!/bin/bash

TEST_DIR=$(dirname "$0")
TEST_DIR=$(
    cd "$TEST_DIR" || exit 2
    pwd
)
ROOT_DIR=$(dirname "$TEST_DIR")

if [ -f "$ROOT_DIR/functions/common.sh" ]; then
    # shellcheck disable=SC1091
    source "$ROOT_DIR/functions/common.sh"
    # shellcheck disable=SC1091
    source "$ROOT_DIR/functions/functions.sh"
    # shellcheck disable=SC1091
    source "$ROOT_DIR/functions/hive.sh"
fi

test_get_decorated_info() {
    message=$(get_decorated_info "Start Authenticate!")
    echo "$message"
    msg=$(get_decorated_info "Start Authenticate!" "+")
    echo "$msg"
}

test_find_file() {
    find_file_by_name "/Users/panchenxi/Opt/module/hive-3.1.2/lib" "*.jar"
}

test_get_decorated_info
# test_find_file
# get_all_system_vars | grep "HIVE"
# close_hive_service
