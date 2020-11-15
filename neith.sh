#!/bin/sh

help()
{
    echo -e "Help:\n====="
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

    echo -e "Notes:\n======"
    echo "* Neith's default print behavior is to only show the total number of symbols found in the given binary"
    echo "* You can use -s and -o at the same time"
    echo "* You can use -q and -o at the same time"
    echo "* You CANNOT use -s and -q at the same time"
}

search_sym()
{
# Regex to use with grep to find every non-allowed boost symbols
# 'grep -v " u "' is used to exclude every unique global symbol from our search
# The result should be null
    REGEX=" u "

# Read the symbols from given file and concatenate them to the REGEX variable
    while read -r line
    do
        REGEX="${REGEX}|$line"
    done < "$SYMFILE"

# Summary output with every forbidden symbols we have found
    if [ -n "$OUTPUT_FILE" ]
    then
        rm "$OUTPUT_FILE"
        nm -C -g --defined-only "$BINARY" | grep boost | grep -Ev "$REGEX" |
        while read -r line
        do
           echo "$line" | awk '{$1=$2=""; print $0}' | sed 's/^ *//g' >> "$OUTPUT_FILE"
        done

        RES=$(wc -l < "$OUTPUT_FILE")

        if [ "$STDOUT" = "y" ]
        then
            cat "$OUTPUT_FILE"
            echo ""
        fi

        echo "" >> "$OUTPUT_FILE"
        echo -e "Forbidden symbols found: $RES" | tee -a "$OUTPUT_FILE"
        exit 0
    else
        RES=$(nm -C -g --defined-only "$BINARY" | grep boost | grep -Ev "$REGEX" | wc -l)
    fi

    echo -e "Forbidden symbols found: $RES"
}

OUTPUT_FILE=""
QUIET=""
STDOUT=""

while getopts "b:f:o:sqh" option
do
    case "${option}"
    in
        b)
            BINARY=${OPTARG}
            ;;

        f)
            SYMFILE=${OPTARG}
            ;;

        o)
            OUTPUT_FILE=${OPTARG}
            ;;

        s)
            STDOUT="y"
            ;;

        q)
            QUIET="y"
            ;;

        h)
            help
            exit 0
            ;;
    esac
done

# Argument sanity begin
if [ -z "$BINARY" ] || [ -z "$SYMFILE" ]
then
    echo -e "Missing mandatory arguments.\n"
    help
    exit 1
fi

if [ -n "$STDOUT" ] && [ -n "$QUIET" ]
then
    echo -e "Invalid mix of arguments, you CANNOT use stdout and quiet options at the same time\n"
    help
    exit 1
fi

# Argument sanity end

if [ "$QUIET" = "y" ]
then
    search_sym > /dev/null
else
    search_sym
fi

exit 0
