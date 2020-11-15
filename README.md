# Neith

## Boost symbol detector
This project will find if the given symbol are used in your binary.  
It won't look through shared objects.

The main focus is to regulate the use of exclusives symbols for a school
project.

Look at `example-symbols.txt` to see how to write the symbols file.
You can use neith to hunt for other symbols than the one in boost,
edit line 35 in neith.sh or remove it completely depending on your usage :)

## Usage
Help:\n====="
Usage: ./neith.sh -b binary -f symbol_file [-o outputfile|-s|-q|-h]

-b :
* Binary to inspect
* Mandatory

-f :
* Specify file containing the forbidden symbols to find
* Mandatory

-o :
* Specify output file
* All forbidden symbols found will be written in this file
* Overwrite existing file

-s :
* Stdout options
* Print forbidden symbols found to stdout
* It's going to print EVERYTHING to stdout

-q :
* Full quiet mode
* NOTHING will print, it's better to use it with -o option

-h :
* Print usage

## Notes
* Neith's default print behavior is to only show the total number of symbols found in the given binary
* You can use -s and -o at the same time
* You can use -q and -o at the same time
* You CANNOT use -s and -q at the same time
* Shellcheck compliant ! (exception: SC2039)

### Developer's notes
Neith is a famous egyptian goddess, she was the goddess of hunting at some
point and here we are hunting for boost symbol :)  
<https://en.wikipedia.org/wiki/Neith>

### Authors
Amandine Nassiri <amandine.nassiri@epita.fr>  
https://github.com/AnSpake/neith
