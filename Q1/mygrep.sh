#!/bin/bash

############### (1) Check options and arguments ###############
# (BONUS) 1.1) Check for '--help' flag to print usage info
if [[ "$1" == "--help" ]]; then
    echo "Usage: mygrep [OPTION]... [MULTIPLE WORDS STRING] [FILEPATH]"
    echo "Search for a STRING in a given FILE."
    echo "Example: mygrep -n 'hello world' testfile.txt"
    echo ""
    echo "Output control:"
    echo "  -n   print line number with output lines"
    echo "  -v   select non-matching lines"
    exit 0
fi

# (BONUS) 1.2) Use 'getopts' for options parsing
isNumbered=false
isVerbose=false
while getopts "nv" option; do
  case $option in
    n) isNumbered=true ;;
    v) isVerbose=true ;;
    *)
        echo "Usage: mygrep [OPTION]... [MULTIPLE WORDS STRING] [FILEPATH]"
        echo "Try 'mygrep --help' for more information."
        exit 1 ;;
  esac
done

# 1.3) Shift options index to focus on args after the options
shift $((OPTIND - 1))

# 1.4) Check for missing string or file path
if [[ $# == 0 ]]; then
    echo "Usage: mygrep [OPTION]... [MULTIPLE WORDS STRING] [FILEPATH]"
    echo "Try 'mygrep --help' for more information."
    exit 1
elif [[ $# == 1 ]]; then
    if [[ -f "$1" ]]; then
        echo "Error: Missing string!"
        exit 1
    else
        echo "Error: File is not found or specified!"
        exit 1
    fi
elif [[ $# > 2 ]]; then
    echo "Error: Too many arguments specified!"
    exit 1
fi

requiredString="$1"
filePath="$2"

############### (2) Search for the required string ###############
# 2.1) Define helper functions and color variables
to_lower(){
    # Converts a string to lowercase
    echo "$1" | tr '[:upper:]' '[:lower:]'
}
count_words() {
    # Counts the number of words in a string
    echo "$1" | wc -w
}
# Color variables
RED='\e[31m'
GREEN='\e[32m'
BLUE='\e[34m'
RESET='\e[0m'

# 2.2) Convert required string to lowercase
requiredString=$(to_lower "$requiredString")
wordsCountInString=$(count_words "$requiredString")

# 2.3) Seudocode of logic
# correctLines=""
# verboseLines=""
# for (int i = 0; i < lines.count; i++):
#   accumulativeLine=""
#   lowerLine=$(to_lower "$lines[i]")
#   wordsCountInLine=$(count_words "$lines[i]")
#   isCorrectLine=false
#   if [[ $wordsCountInString <= $wordsCountInLine ]]
#       for (int j = 0; j < wordsCountInLine; j++):
#           found=false
#           foundString=""
#           currentWord=$lines[i][j]
#           jSteps=0
#           for (int k = 0; k < wordsCountInString; k++):
#               if [[ $requiredString[k] == currentWord ]]; then
#                   found=true
#                   foundString += ${RED}$currentWord${RESET}
#                   j++
#                   jSteps++
#               else
#                   found=false
#                   j -= jSteps
#                   break
#               fi
#           if [[ found ]]; then
#               accumulativeLine += "$foundString"
#               isCorrectLine=true
#           else
#               accumulativeLine += "$currentWord"
#           fi
#       if [[ isCorrectLine ]]; then
#           correctLines += "\n$accumulativeLine"
#       else
#           verboseLines += "\n$accumulativeLine"
#   else
#       verboseLines += "\n$lines[i]"
#   fi

# 2.4) Implement logic
IFS=$'\n' read -d '' -r -a lines < "$filePath"

correctLines=""
verboseLines=""

IFS=' ' read -r -a requiredWords <<< "$requiredString"
wordsCountInString=${#requiredWords[@]}

for (( i=0; i<${#lines[@]}; i++ )); do
    accumulativeLine=""
    if [[ $isNumbered == true ]]; then
        accumulativeLine="${GREEN}$(($i+1))${BLUE}:${RESET}"
    fi
    wordsCountInLine=$(count_words "${lines[i]}")
    isCorrectLine=false

    if [[ $wordsCountInString -le $wordsCountInLine ]]; then
        IFS=' ' read -r -a currentLineWords <<< "${lines[i]}"

        j=0
        while [[ $j -lt $wordsCountInLine ]]; do
            found=false
            foundString=""
            currentWord=${currentLineWords[j]}
            currentWordLower=$(to_lower "${currentWord}")
            jSteps=0

            for (( k=0; k<$wordsCountInString; k++ )); do
                if [[ "${requiredWords[k]}" == "$currentWordLower" ]]; then
                    found=true
                    foundString+="${RED}${currentWord}${RESET} "
                    ((j++))
                    ((jSteps++))
                    currentWord=${currentLineWords[j]}
                    currentWordLower=$(to_lower "${currentWord}")
                else
                    found=false
                    ((j -= jSteps))
                    break
                fi
            done

            if [[ $found == true ]]; then
                accumulativeLine+="$foundString"
                isCorrectLine=true
            else
                accumulativeLine+="${currentLineWords[j]} "
                ((j++))
            fi
        done

        if [[ $isCorrectLine == true ]]; then
            if [[ -n "$correctLines" ]]; then
                correctLines+=$'\n'
            fi
            correctLines+="$accumulativeLine"
        else
            if [[ -n "$verboseLines" ]]; then
                verboseLines+=$'\n'
            fi
            verboseLines+="$accumulativeLine"
        fi
    else
        if [[ -n "$verboseLines" ]]; then
            verboseLines+=$'\n'
        fi
        verboseLines+="${lines[i]}"
    fi
done

if [[ $isVerbose == true ]]; then
    echo -e "$verboseLines"
else
    echo -e "$correctLines"
fi
