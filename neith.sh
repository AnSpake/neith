#!/bin/sh

# User must pass the path to their program in input
BINARY="$1"

# Regex to use with grep to find every non-allowed boost symbols
REGEX="boost"

# 'grep -v " u "' is used to exclude every unique global symbol from our search
# The result should be null
RES=$("nm -C -g --defined-only $BINARY | grep -v ' u ' | grep $REGEX")
