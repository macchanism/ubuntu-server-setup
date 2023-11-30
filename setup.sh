#!/bin/bash

set -e

# スクリプトのディレクトリを取得
function getCurrentDir() {
    local current_dir="${BASH_SOURCE%/*}"
    if [[ ! -d "${current_dir}" ]]; then current_dir="$PWD"; fi
    echo "${current_dir}"
}

# 外部スクリプトを読込
function includeDependencies() {
    # shellcheck source=./setupLibrary.sh
    source "${current_dir}/setupLibrary.sh"
}

current_dir=$(getCurrentDir)
includeDependencies
output_file="output.log"

# ユーザに対話的に質問し，設定
function main() {
    # 新しい非ルートユーザの作成，または既存のユーザアカウントの更新
    read -rp "Do you want to create a new non-root user? (Recommended) [Y/N] " createUser

    # Run setup functions
    trap cleanup EXIT SIGHUP SIGINT SIGTERM

    if [[ $createUser == [nN] ]]; then
        username=$(whoami)
        updateUserAccount "${username}"
    elif [[ $createUser == [yY] ]]; then
        read -rp "Enter the username of the new user account: " username
        addUserAccount "${username}"
    else
	echo 'This is not a valid choice!'
	exit 1
    fi

    # ユーザーによるSSHキーの入力
    read -rp $'Paste in the public SSH key for the new user:\n' sshKey
    echo 'Running setup script...'
    logTimestamp "${output_file}"

    exec 3>&1 >>"${output_file}" 2>&1


    # sudoのパスワードなし設定，SSHキーの追加，SSHの設定変更
    disableSudoPassword "${username}"
    addSSHKey "${username}" "${sshKey}"
    changeSSHConfig
    # UFWの設定
    setupUfw

    # Swapの設定
    if ! hasSwap; then
        setupSwap
    fi

    # タイムゾーンの設定
    setupTimezone

    # NTPの設定
    echo "Configuring System Time... " >&3
    configureNTP

    # SSHサービスの再起動
    sudo service ssh restart

    cleanup

    echo "Setup Done! Log file is located at ${output_file}" >&3
}

# Swap領域の設定と調整
function setupSwap() {
    createSwap
    mountSwap
    tweakSwapSettings "10" "50"
    saveSwapSettings "10" "50"
}

# 既にSwapを使用しているかどうかを確認
function hasSwap() {
    [[ "$(sudo swapon -s)" == *"/swapfile"* ]]
}

# スクリプトが変更した設定のクリーンアップ
function cleanup() {
    if [[ -f "/etc/sudoers.bak" ]]; then
        revertSudoers
    fi
}

# ログファイルにタイムスタンプを追加
function logTimestamp() {
    local filename=${1}
    {
        echo "===================" 
        echo "Log generated on $(date)"
        echo "==================="
    } >>"${filename}" 2>&1
}

# タイムゾーンの設定
function setupTimezone() {
    echo -ne "Enter the timezone for the server (Default is 'Asia/Singapore'):\n" >&3
    read -r timezone
    if [ -z "${timezone}" ]; then
        timezone="Asia/Singapore"
    fi
    setTimezone "${timezone}"
    echo "Timezone is set to $(cat /etc/timezone)" >&3
}

main
