

if [ "$(readlink $0)" == "" ]; then
    cd $(dirname $0)
else
    cd $(dirname $(readlink $0))
fi

SCRIPT_PATH=$(pwd)
cd - > /dev/null

if [ -f "$SCRIPT_PATH/../includes/utils.sh" ]; then
    source "$SCRIPT_PATH/../includes/utils.sh"
else
    echo "[ERROR] The $SCRIPT_PATH/../includes/utils.sh\" file is missing."
    exit 1
fi

SCRIPT_NAME='Install common packages'
SCRIPT_VERSION='1.0'

######################################################################################################

## Is Simulation mode one or off [true/false]
SIMULATION_MODE=false

while [ "$1" != "" ]; do
    case $1 in
#        -h | --help                    ) print_usage; exit;;
        -v | --version                 ) print_version; exit;;
             --print-name              ) print_name; exit;;
             --simulate                ) SIMULATION_MODE=true;;
             --verbose                 ) BE_VERBOSE=true;;
#             --completion-script       ) completion_script; exit;;
        *                              ) print_error "Invalid call. Please, run '$0 -h' for usage info."; exit 1
    esac
    shift
done


#################### [ Installing common packages ] ####################
function _run() {
    echo
    echo -e " ${CYAN}[ Installing common packages ]${NC}"
    echo -e "\n\n[ Installing common packages ]" >>$LOG_FILE_PATH

    declare -a COMMON_PKG_LIST=(
        'software-properties-common'
        'zsh'
        'zsh-syntax-highlighting'
        'zsh-autosuggestions'
        'gnome-tweak-tool'
        'openjdk-8-jdk'
        'openjdk-11-jdk'
        'openjdk-17-jdk'
        'maven'
        'git'
        'gitk'
        'p7zip'
        'rar'
        'htop'
        'tmux'
        'axel'
        'curl'
        'wget'
        'tree'
        'openvpn'
        'tlp'
        'virtualbox'
        'secure-delete'
        'evolution'
        'evolution-ews'
        'tcptrack'
        'openconnect'
        'network-manager-openvpn'
        'network-manager-openvpn-gnome'
        'network-manager-l2tp'
        'network-manager-l2tp-gnome'
        'network-manager-sstp'
        'network-manager-sstp-gnome'
        'network-manager-openconnect'
        'network-manager-openconnect-gnome'
        'network-manager-fortisslvpn'
        'network-manager-fortisslvpn-gnome'
        'network-manager-vpnc'
        'network-manager-vpnc-gnome'
        'network-manager-strongswan'
    )

    for pkg in "${COMMON_PKG_LIST[@]}"; do
        write_log "[ CURRENT STEP ]: Installing ${pkg}..."
        printf "${NC}\t%s %s [...]" ${pkg} "${PADD_LINE:${#pkg}}"
        if [ $SIMULATION_MODE == true ]; then
            status=$(apt-get install -qq -s -y ${pkg} 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
        else
            status=$(apt-get install -qq -y ${pkg} 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
        fi
        printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" ${pkg} "${PADD_LINE:${#pkg}}" "${status}"
    done
    echo -e " ${DARK_GREEN}[ DONE ]${NC}"
}

_run
