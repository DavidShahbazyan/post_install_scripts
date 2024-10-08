

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

SCRIPT_NAME='Install Helm cli'
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

######################################################################################################

function _run() {
    echo
    echo -e " ${CYAN}[ Installing Helm cli ]${NC}"
    write_log "\n\n[ Installing Helm cli ]"

    write_log ''
    msg="Create dir /etc/apt/keyrings if not exists"
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(([ -d /etc/apt/keyrings ] || mkdir /etc/apt/keyrings) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Fetching signing key'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$((curl https://baltocdn.com/helm/signing.asc | apt-key add -) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Generating helm-stable-debian.list file'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
#        status=$((echo -e "Types: deb\nArchitectures: $(dpkg --print-architecture)\nURIs: https://packages.cloud.google.com/apt\nSuites: cloud-sdk\nComponents: main\nSigned-By: /etc/apt/keyrings/kubernetes-apt-keyring.gpg" > /etc/apt/sources.list.d/kubernetes.sources) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
        status=$((echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Installing'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$((apt update && apt install -y helm) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"


    echo -e " ${DARK_GREEN}[ DONE ]${NC}"
}

_run
