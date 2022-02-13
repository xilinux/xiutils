#!/bin/sh

PREFIX=$1

headerfile=${PREFIX}"/include/colors.h"
shlib=${PREFIX}"/lib/colors.sh"

cat > $shlib << "EOF"
#
# colors.h
#
# list of ansi color codes
# provided by xiutils
#

EOF

cat > $headerfile << "EOF"
/*
 * colors.h
 *
 * list of ansi color codes
 * provided by xiutils
 *
 */

EOF

append_header() {
    echo "#define $1 $2" >> $headerfile
}

append_sh() {
    echo "export $1=$2" >> $shlib
}

while IFS= read -r line; do
    grep -q "." <<< "$line" || continue
    name=$(echo $line | awk '{ print $1 }')
    code=$(echo $line | awk '{ print $2 }')

    append_header $name $code
    append_sh $name $code
    
done < "$2"