

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

SCRIPT_NAME='Run UPDATE/UPGRADE/FULL-UPGRADE/CLEANUP'
SCRIPT_VERSION='1.0'

######################################################################################################

## Is Simulation mode one or off [true/false]
SIMULATION_MODE=false
BE_VERBOSE=false


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

#####################################################################################################

function _run() {
    echo
    echo -e " ${CYAN}[ UPDATE / UPGRADE / FULL-UPGRADE / CLEANUP ]${NC}"
    write_log "\n\n[ UPDATE / UPGRADE / FULL-UPGRADE / CLEANUP ]"

    write_log ''
    msg='UPDATE'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(apt-get update 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='UPGRADE'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(apt-get upgrade -y 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='FULL-UPGRADE'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(apt-get full-upgrade -y 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='AUTOREMOVE'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(apt-get autoremove -y 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='AUTOCLEAN'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(apt-get autoclean -y 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    echo -e " ${DARK_GREEN}[ DONE ]${NC}"
}

_run
