#!/bin/bash

if [ "$(readlink $0)" == "" ]; then
    cd $(dirname $0)
else
    cd $(dirname $(readlink $0))
fi

SCRIPT_PATH=$(pwd)
cd - > /dev/null

if [ -f "$SCRIPT_PATH/includes/utils.sh" ]; then
    source "$SCRIPT_PATH/includes/utils.sh"
else
    echo "[ERROR] The $SCRIPT_PATH/includes/utils.sh\" file is missing."
    exit 1
fi

SCRIPT_NAME='Post-install scripts luncher'
SCRIPT_VERSION='1.0'

APP_ARGS='-h --help -v --version --only-once --skip-countdown --simulate --verbose --completion-script'

######################################################################################################

SIMULATION_MODE=false
SKIP_COUNTDOWN=false
BE_VERBOSE=false
IS_INFINITE_ITERATION_ENABLED=true
AVAILABLE_MODULES=()
EXIT_MENU_INDEX=0
RUN_ALL_MODULES_MENU_INDEX=-1

ALL_BANNERS=(
    "                                                    ${LIGHT_GREEN}========================                   \n                                              ${LIGHT_GREEN}========================${NC} ${DARK_GREEN}========${NC}                \n                                           ${LIGHT_GREEN}========================${NC} ${DARK_GREEN}===============${NC}             \n                                        ${LIGHT_GREEN}========================${NC} ${DARK_GREEN}=====================${NC}          \n                                      ${LIGHT_GREEN}========================${NC}  ${DARK_GREEN}========================${NC}        \n                                    ${LIGHT_GREEN}========================${NC}     ${DARK_GREEN}========================${NC}      \n                                   ${LIGHT_GREEN}========================${NC}      ${DARK_GREEN}========================${NC}     \n                                  ${LIGHT_GREEN}========================${NC}                                    \n${CYAN}+++++++++${NC}                        ${LIGHT_GREEN}========================${NC}                        ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}             ${LIGHT_GREEN}==============================================${NC}             ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}               ${LIGHT_GREEN}==========================================${NC}               ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                 ${LIGHT_GREEN}======================================${NC}                 ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                   ${LIGHT_GREEN}=================================${NC}                    ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                      ${LIGHT_GREEN}============================${NC}                      ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                        ${LIGHT_GREEN}========================${NC}                        ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                          ${LIGHT_GREEN}====================${NC}                          ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                            ${LIGHT_GREEN}================${NC}                            ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                              ${LIGHT_GREEN}===========${NC}                               ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                                ${LIGHT_GREEN}=======${NC}                                 ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                                  ${LIGHT_GREEN}===${NC}                                   ${CYAN}+++++++++${NC}\n${CYAN}+++++++++${NC}                                                                        ${CYAN}+++++++++${NC}\n${CYAN}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}\n${CYAN}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}\n${CYAN}++++++++++ ${YELLOW}An automated script that will help to install some usefull packages${NC} ${CYAN}+++++++++++${NC}\n${CYAN}++++++++++ ${YELLOW}AUTHOR: David Shahbazyan${NC} ${CYAN}++++++++++++++++++++++++++++++++++++${NC} ${YELLOW}v.${SCRIPT_VERSION}${NC} ${CYAN}+++++++++++${NC}\n${CYAN}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}\n  ${CYAN}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}  "
    "                                          ${LIGHT_GREEN}####        ####${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                          ${LIGHT_GREEN}###+--------+###${NC}                                          \n                                ${LIGHT_GREEN}#############+--------+#############${NC}                                \n                                ${LIGHT_GREEN}############++--------++############${NC}                                \n                                  ${LIGHT_GREEN}#####++------------------++######${NC}                                 \n                                   ${LIGHT_GREEN}######++--------------+++#####${NC}                                   \n                                     ${LIGHT_GREEN}######++-----------++#####${NC}                                     \n                                      ${CYAN}--+${LIGHT_GREEN}####+--------++###${CYAN}+--+${NC}                                     \n                                ${CYAN}#####+----+${LIGHT_GREEN}###++----++###${CYAN}+----+#####${NC}                                \n                            ${CYAN}########+---..--+${LIGHT_GREEN}###++++###${CYAN}+-------+########${NC}                            \n                         ${CYAN}#######+++---.....---+${LIGHT_GREEN}######${CYAN}++----------+++########${NC}                        \n                     ${CYAN}########++----..........---+${LIGHT_GREEN}##${CYAN}++----------------++########${NC}                     \n                  ${CYAN}########++----..............--------------------------++########${NC}                  \n                 ${CYAN}######+-----.........${YELLOW}An automated script that${NC}${CYAN}--------------+#######${NC}                \n               ${CYAN}#######++--..............${YELLOW}will help to install${NC}${CYAN}----------------++#######${NC}               \n             ${CYAN}#####+-++###++-----.......${YELLOW}some usefull packages${NC}${CYAN}-------------++####+-+#####${NC}             \n            ${CYAN}####+-....-+++##++-----..............---------------------++###++---.--+#####${NC}           \n          ${CYAN}#####+-........--++##+++----${YELLOW}AUTHOR: David Shahbazyan${NC}${CYAN}----+++###++---.....--+#####${NC}          \n         ${CYAN}####+-.............--++###++---.......${YELLOW}v.${SCRIPT_VERSION}${NC}${CYAN}-----------++###++----..........--+####${NC}         \n         ${CYAN}#####+--...............--+####++--......----------++####++----...........--++#####${NC}         \n          ${CYAN}#######+--...............--+####++--...-------++####++------.........--++#######${NC}          \n             ${CYAN}#######++-................-+####++------++####++--..........-----++#######${NC}             \n                ${CYAN}#######++--...............-++###++++###++---..........-----++#######${NC}                \n                 ${CYAN}###+-++##++--...............-+######+---...........---+++##++-+###${NC}                 \n                 ${CYAN}###-...--+###++-............-+######+-..........---++###++--..-###${NC}                 \n                 ${CYAN}###-......--+###++--.......-+########+--.....---++###++--.....-###${NC}                 \n                 ${CYAN}###-..........-+####+--..--###-+##+-+##+-----+####+--.........-###${NC}                 \n                 ${CYAN}###-.............-++###+++##+-.-##+.-+###++####+-.............-###${NC}                 \n                 ${CYAN}###-................-++###++-..-##+..-++###++--...............-###${NC}                 \n                 ${CYAN}###-...................----....-##+....----...................-###${NC}                 \n                 ${CYAN}###+--.........................-##+.........................--+###${NC}                 \n                 ${CYAN}######+--......................-##+.....................--++######${NC}                 \n                   ${CYAN}#######++--..................-##+..................--++########${NC}                  \n                      ${CYAN}#######++--...............-##+...............--++#######${NC}                      \n                         ${CYAN}########++-............-##+............--+########${NC}                         \n                             ${CYAN}########+-.........-##+.........-+########${NC}                             \n                                ${CYAN}#######++--.....-##+.....--++#######${NC}                                \n                                   ${CYAN}########+--..-##+..--++#######${NC}                                   \n                                       ${CYAN}#######+++##+++########${NC}                                      \n                                          ${CYAN}################${NC}                                          \n                                             ${CYAN}##########${NC}                                             "
    " ${CYAN}┌─────────────────────────────────────────────────────────────────────┐${NC}\n ${CYAN}│ ${YELLOW}An automated script that will help to install some useful packages${CYAN}  │${NC}\n ${CYAN}│ ${YELLOW}AUTHOR: David Shahbazyan${CYAN}                                      ${YELLOW}v.${SCRIPT_VERSION}${CYAN} │${NC}\n ${CYAN}└─────────────────────────────────────────────────────────────────────┘${NC}"
)

function print_banner {
    echo
    RANDOM_INDEX=$(( ( RANDOM % ${#ALL_BANNERS[@]} ) ))
    # echo "Random index: ${RANDOM_INDEX}"
    echo -e "${ALL_BANNERS[$RANDOM_INDEX]}"
}

function print_usage {
    print_banner
    echo -e " USAGE: $0 [OPTIONS] $NC"
    echo
    echo -e " AVAILABLE OPTIONS:"
    echo -e "     -h | --help                 Print this message and exit"
    echo -e "     -v | --version              Prints script version and exit"
    echo -e "          --only-once            Exit after the first installation process (Default is $([ ${IS_INFINITE_ITERATION_ENABLED} == true ] && echo 'false' || echo 'true'))"
    echo -e "          --skip-countdown       Skip countdown part (Default is ${SKIP_COUNTDOWN})"
    echo -e "          --verbose              Be verbose (Default is ${BE_VERBOSE})"
    echo -e "          --completion-script    Prints out the auto-completion script"
    echo
    echo -e "          --simulate             Run the script in 'simulation' mode."
    echo -e "                                 Will not make any real changes (Default is ${SIMULATION_MODE})"
    echo
}


while [ "$1" != "" ]; do
    case $1 in
        -h | --help                    ) print_usage; exit;;
        -v | --version                 ) print_version; exit;;
             --only-once               ) IS_INFINITE_ITERATION_ENABLED=false;;
             --skip-countdown          ) SKIP_COUNTDOWN=true;;
             --simulate                ) SIMULATION_MODE=true;;
             --verbose                 ) BE_VERBOSE=true;;
             --completion-script       ) completion_script; exit;;
        *                              ) print_error "Invalid call. Please, run '$0 -h' for usage info."; exit 1
    esac
    shift
done

function load_available_modules() {
#    readarray -d '' AVAILABLE_MODULES < <(find "${SCRIPT_PATH}/modules" -name "*.module" -print0; printf "$?")
    readarray -d '' AVAILABLE_MODULES < <(find "${SCRIPT_PATH}/modules" -name "*.module.sh" -print0)
    IFS=$'\n' AVAILABLE_MODULES=($(sort <<<"${AVAILABLE_MODULES[*]}")); unset IFS
}

function print_menu {

    # echo -e "${CYAN} 🖹 Choose what do you want to do:${NC}"

    echo -e " ${CYAN}🗒 Choose what do you want to do:${NC}"

    for i in "${!AVAILABLE_MODULES[@]}"; do
        print_menu_row "$(($i + 1))" "$(bash ${AVAILABLE_MODULES[$i]} --print-name)"
    done
    RUN_ALL_MODULES_MENU_INDEX=$(($i + 2))
    echo -e " ${NC}$(print_n_times '─' 60)${CLEAR_REST_OF_LINE}"
    print_menu_row "${RUN_ALL_MODULES_MENU_INDEX}" "ALL ABOVE"
    print_menu_row "${EXIT_MENU_INDEX}" "EXIT"
}

function invoke_module {
    write_log "Module: ${1}"
    write_log "Params: ${2}"
    bash $1 $2
    write_log "\n────────────────────────────────────────────────────────"
}

function _start() {
    passThroughParams=''
    [ ${SIMULATION_MODE} == true ] && passThroughParams="${passThroughParams} --simulate"
    [ ${BE_VERBOSE} == true ] && passThroughParams="${passThroughParams} --verbose"

    echo "PassThroughParams: ${passThroughParams}"

    #################### [ Loading modules list ] ####################
    load_available_modules

    clear
    print_banner

    show_countdown

    while true; do
        echo
        echo
        echo -e "${YELLOW} ➣ Simulation mode is:${NC} $(if [ $SIMULATION_MODE == true ]; then echo ${DARK_GREEN}'ON (no real changes will be done)'${NC}; else echo ${RED}'OFF (any choice you do will make real changes to your OS)'${NC}; fi)"

        echo
        print_menu
        [ "${invalid_coice_error}" != '' ] && print_error "${invalid_coice_error}"
        echo

        read -r -p "$(echo -e "${CYAN} ➣ Please, select the task index or press [Ctrl+C] to exit: ${NC}")" index
        if [[ $index -ge 0 && $index -le $((${#AVAILABLE_MODULES[@]} + 2)) ]]; then

            # "EXIT" menu item selected
            if [[ $index -eq ${EXIT_MENU_INDEX} ]]; then
                exit_app
            fi

            # "ALL ABOVE" menu item selected
            if [[ $index -eq $((${#AVAILABLE_MODULES[@]} + 1)) ]]; then
                echo -e "${YELLOW} 🗹 Your choice was:${NC} ${DARK_GREEN}ALL ABOVE${NC}"
                for module in ${AVAILABLE_MODULES[@]}; do
                    bash ${module} $passThroughParams
                done
            # Any other menu item selected
            else
                echo -e "${YELLOW} 🗹 Your choice was:${NC} ${DARK_GREEN}$(bash ${AVAILABLE_MODULES[$((index - 1))]} --print-name)${NC}"
                invoke_module ${AVAILABLE_MODULES[$((index - 1))]} "$passThroughParams"
            fi
            invalid_coice_error=''

            if [ ${IS_INFINITE_ITERATION_ENABLED} == true ]; then
                show_countdown
            else
                exit_app
            fi
        else
            invalid_coice_error='Invalid index! Please, select one from list above.'
        fi
    done
}


_start
