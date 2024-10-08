#!/bin/bash
set -o pipefail

export CLEAR_REST_OF_LINE='\033[0K'
export NC='\033[0m'
export DARK_GREEN='\033[0;32m'
export RED='\033[0;31m'
export YELLOW='\033[0;33m'
export CYAN='\033[0;36m'
export LIGHT_GREEN='\033[1;32m'

export LOG_FILE_DIR='/tmp'
export LOG_FILE_NAME='post_install.sh.log'
export LOG_FILE_PATH="${LOG_FILE_DIR}/${LOG_FILE_NAME}"
export PADD_LINE='------------------------------------------------------------'
#export PADD_LINE='────────────────────────────────────────────────────────────'

export DONE_SYMBOL='✔' # OK | ✔ | 🗸
export FAILED_SYMBOL='✗' # Failed | ✗ | 🗶

export SCRIPT_NAME=''
export SCRIPT_VERSION=''
export APP_ARGS=''

export TERM_COLUMNS=`tput cols`

function do_beep {
    echo -en '\007'
}

function clear_line {
    echo -en '\r'$CLEAR_REST_OF_LINE
}

function clear_line_tail {
    echo -en $CLEAR_REST_OF_LINE
}

function clear_screen {
#    clear
    echo
}

###################################
# $1 - Symbol to print
# $2 - How many times to print
function print_n_times {
    printf "%0.s$1" $(seq 1 $2);
}

function print_hr {
    printf $NC
    print_n_times "─" $(($TERM_COLUMNS - 1))
    printf $NC'\n'
}

###################################
# $1 - Text to print
# $2 - Color
function print_separator_text {
    str_length=`echo -en "$1" | wc -c`
    dash_length=$((($TERM_COLUMNS - $str_length - 5) / 2))
    printf $NC
    print_n_times "─" $dash_length
    printf "[ $2$1$NC ]"
    print_n_times "─" $dash_length
    print_n_times "─" $(($TERM_COLUMNS - ($dash_length * 2 + $str_length + 5)))
    printf $NC'\n'
}

function print_done {
    do_beep
    print_separator_text 'DONE' $DARK_GREEN
    # notify-send "$SCRIPT_NAME" "DONE!"
}

###################################
# $1 - Text to print
function print_ln_inline {
    clear_line
    echo -en $NC'['$CYAN`date '+%H:%M:%S'`$NC"] $1"$NC
}

###################################
# $1 - Text to print
function print_ln {
    print_ln_inline "$1"
    echo
}

###################################
# $1 - Text to print
function print_info_inline {
    clear_line
    echo -en $NC'['$CYAN`date '+%H:%M:%S'`$NC'] ['$DARK_GREEN'INFO'$NC"] $1"$NC
}
function print_info {
    print_info_inline "$1"
    echo
}

###################################
# $1 - Text to print
function print_warning_inline {
    clear_line
    echo -en $NC'['$CYAN`date '+%H:%M:%S'`$NC'] ['$YELLOW'WARNING'$NC"] $1"$NC
}
function print_warning {
    print_warning_inline "$1"
    echo
}

###################################
# $1 - Text to print
function print_error_inline {
    do_beep
    clear_line
    echo -en $NC'['$CYAN`date '+%H:%M:%S'`$NC'] ['$RED'ERROR'$NC"] $1"$NC
}
function print_error {
    print_error_inline "$1"
    echo
}

###################################
# $1 - Text to print
function print_attention_inline {
    do_beep
    clear_line
    echo -en $NC'['$CYAN`date '+%H:%M:%S'`$NC'] ['$RED'ATTENTION'$NC"] $1"$NC
}
function print_attention {
    print_attention_inline "$1"
    echo
}

## Checks if the value is not empty
## $1 - Value
## $2 - Parameter name
function validateValueNotEmpty {
    if [[ $1 == "" ]]; then
        print_error "The value of \"$2\" parameter is mandatory."
        exit 1
    fi
}

## Checks if the value is not starting with '-'
## $1 - Value
## $2 - Parameter name
function validateValueNotStartingWithDash {
    if [[ $1 == -* ]]; then
        print_error "The value of \"$2\" parameter can not start with '-'."
        exit 1
    fi
}

function print_name {
    echo "$SCRIPT_NAME"
}

function print_version {
    echo "$SCRIPT_NAME: v.$SCRIPT_VERSION"
    echo
}

####
## Prints a general menu row
## $1 - The menu row index
## $2 - The menu row text
function print_menu_row() {
    printf "${NC}    %2.5s. %s${CLEAR_REST_OF_LINE}\n" "${1}" "${2}"
}

## Write a message to the LOG_FILE_PATH
## $1 - The message to write
function write_log {
    echo -e "${1}" | tee -a $LOG_FILE_PATH >/dev/null
}

function show_countdown {
    if ! ${SKIP_COUNTDOWN} ; then
        for i in {5..1}; do
            echo -en "\r     Press ${YELLOW}[Ctrl+C]${NC} to cancel or wait a while to continue... [${i}]${CLEAR_REST_OF_LINE}"
            sleep 1
        done
        echo -en "\r${CLEAR_REST_OF_LINE}"
    fi
}

function exit_app {
    echo
    echo -e "${YELLOW} ➣ Bye!${NC}"
    exit
}

function completion_script {
    SCRIPT_NAME=$(echo $0 | awk -F/ '{print $NF}')
    METHOD_NAME=$(echo $0 | awk -F/ '{print $NF}' | awk -F. '{print $1}')

    data=$(cat <<EOF
#
# Please, append the line below to the end of your .bashrc/.zshrc file to enable the completion feature
# [[ \$($METHOD_NAME -h) ]] && source <($METHOD_NAME --completion-script)
#
####
# Author: David Shahbazyan <d.shahbazyan@gmail.com>
# completion for $SCRIPT_NAME
#
_$METHOD_NAME()
{
    local cur

    COMPREPLY=()
    cur=\${COMP_WORDS[COMP_CWORD]}
    if [[ "\$cur" == -* ]] ; then
        args='$APP_ARGS'
        COMPREPLY=( \$( compgen -W "\${args}" -- "\$cur" ) )
    else
        comptopt -o filenames 2>/dev/null
        COMPREPLY=( \$(compgen -f -- \${cur}) )
    fi
}
complete -o filenames -F _$METHOD_NAME $SCRIPT_NAME
EOF
)

    echo "$data"
}

# function enable_auto_completion {
#     SCRIPT_NAME=$(echo $0 | awk -F/ '{print $NF}')
#     METHOD_NAME=$(echo $0 | awk -F/ '{print $NF}' | awk -F. '{print $1}')
# 
#     data=$(cat <<EOF
# 
# #
# # Author: David Shahbazyan <d.shahbazyan@gmail.com>
# #
# # completion for $SCRIPT_NAME
# 
# _$METHOD_NAME()
# {
#     local cur
# 
#     COMPREPLY=()
#     cur=\${COMP_WORDS[COMP_CWORD]}
#     if [[ "\$cur" == -* ]] ; then
#         args='$APP_ARGS'
#         COMPREPLY=( \$( compgen -W "\${args}" -- "\$cur" ) )
#     else
#         comptopt -o filenames 2>/dev/null
#         COMPREPLY=( \$(compgen -f -- \${cur}) )
#     fi
# }
# complete -o filenames -F _$METHOD_NAME $SCRIPT_NAME
# EOF
# )
# 
#     AUTO_COMPLETION_CONFIG_PATH="${HOME}/.bash_completions"
#     # AUTO_COMPLETION_CONFIG_PATH='/usr/share/bash-completion/completions'
#     # [[ -d $AUTO_COMPLETION_CONFIG_PATH ]] || mkdir -p $AUTO_COMPLETION_CONFIG_PATH
# 
#     echo "$data" >> $AUTO_COMPLETION_CONFIG_PATH
# 
#     echo 'An auto-completion config file has been created with path:'
#     echo $AUTO_COMPLETION_CONFIG_PATH
#     echo
#     echo 'Please add a code snippet below in your .bashrc file, and restart your terminal.'
#     echo
#     echo "[[ -f ${AUTO_COMPLETION_CONFIG_PATH} ]] && . ${AUTO_COMPLETION_CONFIG_PATH}"
#     echo
# }
