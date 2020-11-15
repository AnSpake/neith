#!/bin/sh

help()
{
    echo -e "Usage: ./neith.sh [-b binary][-f symbol_file|-o outputfile|-s|-q|-h]\n"

    echo -e "-b :\tBinary to inspect"
    echo -e "\tMandatory\n"

    echo -e "-f :\tSpecify file containing the forbidden symbols to find"
    echo -e "\tMandatory\n"

    echo -e "-o :\tSpecify output file"
    echo -e "\tAll forbidden symbols found will be written in this file"
    echo -e "\tOverwrite existing file\n"

    echo -e "-s :\tPrint forbidden symbols found to stdout\n"
    echo -e "-q :\tFull quiet mode\n"
    echo -e "-h :\tPrint usage\n"

    echo -e "Notes:"
    echo "* Neith's default print behavior is to only show the total number of symbols found in the given binary"
    echo "* You can use -s and -o at the same time"
}

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
    done < "$2"

# Summary output with every forbidden symbols we have found
    if [ ! -z "$OUTPUT_FILE" ]
    then
        rm "$OUTPUT_FILE"
        nm -C -g --defined-only "$BINARY" | grep boost | grep -Ev "$REGEX" |
        while read -r line
        do
           echo "$line" | awk '{$1=$2=""; print $0}' | sed 's/^ *//g' >> "$OUTPUT_FILE"
        done

        RES=$(cat "$OUTPUT_FILE" | wc -l)
    else
        RES=$(nm -C -g --defined-only "$BINARY" | grep boost | grep -Ev "$REGEX" | wc -l)
    fi

    if [ -z "$RES" ]
    then
        echo "No forbidden symbols found."
    else
        echo "Successful hunting: "$RES" forbidden symbols found."
    fi
}

OUTPUT_FILE=""
QUIET="no"

while getopts "b:f:o:sqh" option
do
    case "${option}"
    in
        b)
            BINARY=${OPTARG}
            echo "Binary: $BINARY"
            ;;

        f)
            SYMFILE=${OPTARG}
            echo "Symbols file: $SYMFILE"
            ;;

        o)
            OUTPUT_FILE=${OPTARG}
            echo "Output file: $OUTPUT_FILE"
            ;;

        s)
            echo "Print to stdout: yes"
            ;;

        q)
            echo "Quiet mode: yes"
            ;;

        h)
            help
            exit 0
            ;;
    esac
done

search_sym
exit 0
