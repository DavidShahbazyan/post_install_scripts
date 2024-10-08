

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

SCRIPT_NAME='Install docker'
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
    echo -e " ${CYAN}[ Installing docker ]${NC}"
    write_log "\n\n[ Installing docker ]"

    write_log ''
    msg='Removing docker related packages'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$((for pkg in docker docker-engine docker-compose-plugin docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt remove $pkg; done) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

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
    msg='Fetching GPG key'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Generating docker.sources file'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$((echo -e "Types: deb\nArchitectures: $(dpkg --print-architecture)\nURIs: https://download.docker.com/linux/ubuntu\nSuites: $(lsb_release -cs)\nComponents: stable\nSigned-By: /etc/apt/keyrings/docker.asc" > /etc/apt/sources.list.d/docker.sources) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Installing'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$((apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin) 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"

    write_log ''
    msg='Adding current user to docker group'
    write_log "[ CURRENT STEP ]: ${msg}"
    printf "${NC}\t%s %s [...]" "${msg}" "${PADD_LINE:${#msg}}"
    if [ $SIMULATION_MODE == true ]; then
        status=$(echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC})
    else
        status=$(usermod -aG docker $USER 2>&1 | tee -a $LOG_FILE_PATH >/dev/null && echo -e ${DARK_GREEN}"${DONE_SYMBOL}"${NC} || echo -e ${RED}"${FAILED_SYMBOL}"${NC})
    fi
    printf "\r${NC}\t%s %s [%s]${CLEAR_REST_OF_LINE}\n" "${msg}" "${PADD_LINE:${#msg}}" "${status}"


    echo -e " ${DARK_GREEN}[ DONE ]${NC}"
}

_run
