#!/bin/sh

search_sym()
{
# User must pass the path to their program in input
    BINARY="$1"

# Regex to use with grep to find every non-allowed boost symbols
# 'grep -v " u "' is used to exclude every unique global symbol from our search
# The result should be null
    REGEX=" u "

# Read the symbols from given file and concatenate them to the REGEX variable
    while read -r line
    do
        REGEX="${REGEX}|$line"
    done < symbols.txt

# Summary output with every forbidden symbols we have found
    rm tmp
    touch tmp
    nm -C -g --defined-only "$BINARY" | grep boost | grep -Ev "$REGEX" |
    while read -r line
    do
       echo "$line" | awk '{$1=$2=""; print $0}' | sed 's/^ *//g' >> tmp
    done

    RES=$(cat tmp | wc -l)

    if [ -z "$RES" ]
    then
        echo "No forbidden symbols found."
    else
        echo "Successful hunting: "$RES" forbidden symbols found."
    fi
}

case "$1"
in
    *) search_sym "$1"
esac

exit 0
