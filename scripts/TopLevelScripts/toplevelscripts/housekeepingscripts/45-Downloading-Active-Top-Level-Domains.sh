#!/bin/bash
## This downloads the valid tld lists

## Variables
source ./foldervars.var

for f in $TLDLSTALL
do

## Variables
source ./foldervars.var

## Clear Temp Before
if
[[ -f $DELETETEMPFILE ]]
then
bash $DELETETEMPFILE
else
echo "Error Deleting Temp Files."
exit
fi

printf "$lightblue"    "$DIVIDERBAR"
echo ""

LOOPSTART=$(date +"%s")

## Declare File Name
FILEBEINGPROCESSED=$f
echo "FILEBEINGPROCESSED="$FILEBEINGPROCESSED"" | tee --append $TEMPPARSEVARS &>/dev/null

BASEFILENAME=$(echo `basename $f | cut -f 1 -d '.'`)
echo "BASEFILENAME="$BASEFILENAME"" | tee --append $TEMPPARSEVARS &>/dev/null
echo "## $BASEFILENAME" | sudo tee --append $RECENTRUN &>/dev/null

BREPOLOG="$TLDLISTSSCRIPTSLOGSDIR""$BASEFILENAME".md
echo "RECENTRUN="$BREPOLOG"" | tee --append $TEMPPARSEVARS &>/dev/null
TAGTHEREPOLOG="[Details If Any]("$TLDLISTSSCRIPTSLOGSDIRGIT""$BASEFILENAME".log)"
TAGTHEUPONEREPOLOG="[Go Up One Level]("$TLDLISTSSCRIPTSLOGSDIRGIT""$SCRIPTBASEFILENAME".md)"
TAGTHEUPTWOREPOLOG="[Go Up Two Levels]("$INITIALTASKSSCRIPTSLOGSGIT""$INITIALTASKSSCRIPTBASENAME".md)"

## Create Log
if
[[ -f $BREPOLOG ]]
then
rm $BREPOLOG
fi
echo "$MAINREPOFOLDERGITTAG" | tee --append $BREPOLOG &>/dev/null
echo "$MAINRECENTRUNLOGMDGITTAG" | tee --append $BREPOLOG &>/dev/null
echo "$TAGTHEUPONEREPOLOG" | tee --append $BREPOLOG &>/dev/null
echo "$TAGTHEUPTWOREPOLOG" | tee --append $BREPOLOG &>/dev/null
echo "____________________________________" | tee --append $BREPOLOG &>/dev/null
echo "# $BASEFILENAME" | sudo tee --append $BREPOLOG &>/dev/null

printf "$green"    "Processing $BASEFILENAME List."
echo "## Processing $BASEFILENAME List." | sudo tee --append $BREPOLOG &>/dev/null
echo "" 

for p in $TLDLISTSSCRIPTSALL
do

PBASEFILENAME=$(echo `basename $p | cut -f 1 -d '.'`)
PBASEFILENAMEDASHNUM=$(echo $PBASEFILENAME | sed 's/[0-9\-]/ /g')
PBNAMEPRETTYSCRIPTTEXT=$(echo $PBASEFILENAMEDASHNUM)

printf "$cyan"  "$PBNAMEPRETTYSCRIPTTEXT"
echo "## $PBNAMEPRETTYSCRIPTTEXT" | sudo tee --append $BREPOLOG &>/dev/null
bash $p
echo ""

## End of parsing Loop
done

## Clear Temp After
if
[[ -f $DELETETEMPFILE ]]
then
bash $DELETETEMPFILE
else
echo "Error Deleting Temp Files."
exit
fi

LOOPEND=$(date +"%s")
DIFFTIMELOOPSEC=`expr $LOOPEND - $LOOPSTART`
if
[[ $DIFFTIMELOOPSEC -ge 60 ]]
then
DIFFTIMELOOPMIN=`expr $DIFFTIMELOOPSEC / 60`
LOOPTIMEDIFF="$DIFFTIMELOOPMIN Minutes."
elif
[[ $DIFFTIMELOOPSEC -lt 60 ]]
then
LOOPTIMEDIFF="$DIFFTIMELOOPSEC Seconds."
fi

echo "List Took $LOOPTIMEDIFF" | sudo tee --append $RECENTRUN &>/dev/null
echo "$TAGTHEREPOLOG" | sudo tee --append $RECENTRUN &>/dev/null
echo "" | sudo tee --append $RECENTRUN &>/dev/null
printf "$orange" "$DIVIDERBARB"
echo ""

done
