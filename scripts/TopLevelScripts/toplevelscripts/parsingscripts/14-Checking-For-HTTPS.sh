#!/bin/bash
## This checks for secure connection

## Variables
source ./foldervars.var

## Is source not using https
if
[[ $source != https* ]]
then
printf "$red"    "$BASEFILENAME List Does NOT Use https."
else
printf "$green"    "$BASEFILENAME List Does Use https."
fi
