

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

SCRIPT_NAME='Install GoogleChrome (latest stable)'
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
    echo -e " ${CYAN}[ Installing latest stable GoogleChrome ]${NC}"
    write_log "\n\n[ Installing latest stable GoogleChrome ]"

    write_log ''
    msg='Downloading the current stable installer to /tmp/chrome.deb'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Installing from /tmp/chrome.deb'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(dpkg -i /tmp/chrome.deb 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Removing /tmp/chrome.deb'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(rm /tmp/chrome.deb 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    echo -e " ${DARK_GREEN}[ DONE ]${NC}"
}

_run
