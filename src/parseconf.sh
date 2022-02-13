#!/bin/bash

usage () {
    printf "Usage $0 "
    echo << "EOF"
OPTIONS... [FILTER]

Print the parsed config file filtering by the keys
Arguments:
    -f file         read configuration from a file, uses /dev/sdtin otherwise
    -v              only print values
    -c n            print the last [n]
EOF
}

# print the parsed values from the config file in key:value format
#
parse () {
    local file="$1"
    local level=""
    local list=""
    while IFS= read -r line; do
        line=$(sed "s/\s\+/ /g" <<< "$line" | sed "s/^\s\|\s$\|;*$//g")
        
        grep -q "^#" <<< "$line" && continue
        grep -q "." <<< "$line" || continue

        local key=$(echo $line | cut -d" " -f1)
        local value=$(echo $line | cut -d" " -f2-)

        [ "$key" = "include" ] && parse $value && continue

        case ${value: -1} in 
            "{")
                level="$level$key."
                ;;
            "[")
                list="$list$key."
                printf "$level$key:"
                ;;
            "}")
                level=$(sed "s/[^\.]\w*\.$//g" <<< "$level")
                ;;
            "]")
                printf "\n"
                list=$(sed "s/[^\.]\w*\.$//g" <<< "$list")
                ;;
            *)

                grep -q "." <<< "$list" && 
                    printf "$line " ||
                    printf "$level$key:$value\n"
                ;;
        esac
    done < "$file"
}

# Filter the parsed file for specific keys
#
filter () {
    local pattern=

    [ $# = 0 ] &&
        pattern=".*" ||
        pattern=$(sed "s/\*/[^:]*/g"<<< "$@")

    $print_keys && 
        pattern="s/^($pattern:.+)/\1/p" ||
        pattern="s/^$pattern:(.+)/\1/p"


    parse $CONF_FILE | sed -rn $pattern
}

# Use the env variable if exists
[ -z ${CONF_FILE} ] && CONF_FILE="/dev/stdin"

# initialise options
print_keys=true
count=

while getopts ":f:c:v" opt; do
    case "${opt}" in 
        f)
            [ "${OPTARG}" = "-" ] &&
                CONF_FILE="/dev/stdin" ||
                CONF_FILE="${OPTARG}"
            ;;

        v)
            print_keys=false
            ;;
        c)
            count="${OPTARG}"
            ;;
        *)
    esac
done

shift $((OPTIND-1))

[ -z ${count} ] &&
    filter "$@" ||
    filter "$@" | tail -n $count

